import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'config.dart';
import 'naming.dart';
import 'subscription_events.dart';
import 'subscription_socket.dart';
import 'types.dart';

typedef SubscriptionSocketConnect = Future<WebSocketChannel> Function({
  required Uri uri,
  required Map<String, String> headers,
  required List<String> protocols,
});

/// graphql-transport-ws client. One socket multiplexes every operation.
///
/// Mobile and desktop send the same headers as HTTP. Flutter web cannot set
/// headers, so token auth exchanges a short-lived ticket and carries it in the
/// WebSocket subprotocol. Same-origin cookies still work without a ticket.
///
/// A reconnect emits [ApitoSubscriptionSignal.resyncRequired]. Events missed
/// while the socket was down are not replayed.
class ApitoSubscriptionClient {
  ApitoSubscriptionClient({
    required ApitoConfig config,
    required Map<String, String> Function() headers,
    this.onTokenExpired,
    http.Client? httpClient,
    SubscriptionSocketConnect? connect,
    Random? random,
  })  : _config = config,
        _headers = headers,
        _http = httpClient ?? http.Client(),
        _ownsHttp = httpClient == null,
        _connect = connect ?? connectSubscriptionSocket,
        _random = random ?? Random();

  final ApitoConfig _config;
  final Map<String, String> Function() _headers;
  final void Function()? onTokenExpired;
  final http.Client _http;
  final bool _ownsHttp;
  final SubscriptionSocketConnect _connect;
  final Random _random;

  final _states = StreamController<ApitoConnectionState>.broadcast();
  final _signals = StreamController<ApitoSubscriptionSignal>.broadcast();
  final _ops = <String, _LiveOp>{};
  var _nextId = 0;
  var _state = ApitoConnectionState.idle;
  var _disposed = false;
  var _foreground = true;
  var _acked = false;
  var _hadConnection = false;
  var _authFailed = false;
  var _attempt = 0;
  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _listener;
  Timer? _retry;
  Timer? _ping;
  Future<void>? _connectFuture;

  Stream<ApitoConnectionState> get connectionStates => _states.stream;
  Stream<ApitoSubscriptionSignal> get signals => _signals.stream;
  ApitoConnectionState get connectionState => _state;

  /// Raw graphql-transport-ws operation. Each event is the GraphQL `data` map.
  Stream<Map<String, dynamic>> subscribe(
    String document, {
    Map<String, dynamic>? variables,
  }) {
    final id = '${++_nextId}';
    late final StreamController<Map<String, dynamic>> controller;
    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        _ops[id] = _LiveOp(document, variables ?? const {}, controller);
        _ensureConnected();
      },
      onCancel: () {
        final op = _ops.remove(id);
        if (op != null) {
          op.localComplete = true;
          _send({'id': id, 'type': 'complete'});
        }
      },
    );
    return controller.stream;
  }

  Stream<ModelChangeEvent> modelChanges(
    String model, {
    List<String>? events,
    String? id,
    Map<String, dynamic>? where,
  }) {
    final field = '${apitoSingularResourceName(model)}Changed';
    final document = '''
subscription ${apitoSingularGraphQLTypeName(model)}Changed(\$events: [String!], \$id: String, \$where: JSON) {
  $field(events: \$events, id: \$id, where: \$where) {
    event
    model
    id
    projectId
    node
    previousValues
  }
}
''';
    return subscribe(document, variables: {
      if (events != null) 'events': events,
      if (id != null) 'id': id,
      if (where != null) 'where': where,
    }).map((data) {
      final payload = data[field];
      final event = ModelChangeEvent.fromPayload(
        payload is Map ? Map<String, dynamic>.from(payload) : null,
      );
      if (event == null) {
        throw ApitoError('subscription $field returned no payload');
      }
      return event;
    });
  }

  Stream<BroadcastMessage> broadcast(String channel) {
    const document = r'''
subscription Broadcast($channel: String!) {
  broadcast(channel: $channel) {
    channel
    event
    payload
    at
  }
}
''';
    return subscribe(document, variables: {'channel': channel}).map((data) {
      final payload = data['broadcast'];
      final message = BroadcastMessage.fromPayload(
        payload is Map ? Map<String, dynamic>.from(payload) : null,
      );
      if (message == null) {
        throw ApitoError('broadcast returned no payload');
      }
      return message;
    });
  }

  void setAppInForeground(bool foreground) {
    _foreground = foreground;
    if (!foreground) {
      _pausedClose();
      return;
    }
    if (_ops.isNotEmpty) _ensureConnected();
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _ping?.cancel();
    _dropSocket();
    for (final op in _ops.values) {
      op.controller.close();
    }
    _ops.clear();
    _setState(ApitoConnectionState.closed);
    _states.close();
    _signals.close();
    if (_ownsHttp) _http.close();
  }

  Uri subscriptionUri() {
    final raw = _config.subscriptionEndpoint?.trim();
    if (raw != null && raw.isNotEmpty) return Uri.parse(raw);
    final httpUri = Uri.parse(_config.endpoint);
    final scheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    var path = httpUri.path;
    if (!path.endsWith('/subscription')) {
      path = path.endsWith('/') ? '${path}subscription' : '$path/subscription';
    }
    return httpUri.replace(scheme: scheme, path: path);
  }

  Future<void> _ensureConnected() {
    if (_disposed || !_foreground || _authFailed) return Future.value();
    if (_acked && _socket != null) {
      _flush();
      return Future.value();
    }
    return _connectFuture ??= _open().whenComplete(() {
      _connectFuture = null;
    });
  }

  Future<void> _open() async {
    _retry?.cancel();
    _setState(_hadConnection
        ? ApitoConnectionState.reconnecting
        : ApitoConnectionState.connecting);
    try {
      final headers = Map<String, String>.from(_headers());
      headers.remove('Content-Type');
      var protocols = <String>['graphql-transport-ws'];
      if (subscriptionAuthUsesTicket && _hasCredential(headers)) {
        final ticket = await _issueTicket(headers).timeout(_config.subscriptionConnectTimeout);
        protocols = ['graphql-transport-ws', 'apito-ticket.$ticket'];
        headers.clear();
      }
      final channel = await _connect(
        uri: subscriptionUri(),
        headers: headers,
        protocols: protocols,
      ).timeout(_config.subscriptionConnectTimeout);
      if (_disposed || !_foreground) {
        await channel.sink.close();
        return;
      }
      _socket = channel;
      _acked = false;
      _listener = channel.stream.listen(_onFrame, onError: _onSocketError, onDone: _onSocketDone);
      _send({'type': 'connection_init', 'payload': <String, dynamic>{}});
    } catch (err) {
      if (_isAuthMessage('$err')) {
        _failAuth();
        return;
      }
      _scheduleRetry();
    }
  }

  Future<String> _issueTicket(Map<String, String> headers) async {
    final ws = subscriptionUri();
    final httpScheme = ws.scheme == 'wss' ? 'https' : 'http';
    final path = ws.path.replaceFirst(RegExp(r'/subscription$'), '/subscription-ticket');
    final uri = ws.replace(scheme: httpScheme, path: path);
    final response = await _http.post(uri, headers: {
      ...headers,
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApitoError('subscription ticket rejected', statusCode: response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApitoError('subscription ticket HTTP ${response.statusCode}', statusCode: response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    final ticket = decoded is Map ? decoded['ticket']?.toString() : null;
    if (ticket == null || ticket.isEmpty) {
      throw ApitoError('subscription ticket response was empty');
    }
    return ticket;
  }

  void _onFrame(dynamic raw) {
    final text = raw is String ? raw : utf8.decode(raw as List<int>);
    final decoded = jsonDecode(text);
    if (decoded is! Map) return;
    final frame = Map<String, dynamic>.from(decoded);
    final type = frame['type']?.toString();
    switch (type) {
      case 'connection_ack':
        _acked = true;
        _attempt = 0;
        _setState(ApitoConnectionState.connected);
        _startPing();
        if (_hadConnection) {
          _signals.add(const ApitoSubscriptionSignal(resyncRequired: true));
        }
        _hadConnection = true;
        _flush();
      case 'ping':
        _send({'type': 'pong'});
      case 'pong':
        break;
      case 'next':
        final id = frame['id']?.toString();
        final op = id == null ? null : _ops[id];
        final payload = frame['payload'];
        if (op == null || payload is! Map) return;
        final data = payload['data'];
        if (data is Map) {
          op.controller.add(Map<String, dynamic>.from(data));
        }
        final errors = payload['errors'];
        if (errors is List && errors.isNotEmpty) {
          final message = errors.map((e) => e is Map ? e['message'] : e).join('; ');
          op.controller.addError(ApitoError(message));
          if (_isAuthMessage(message)) _failAuth();
        }
      case 'error':
        final id = frame['id']?.toString();
        final message = _errorText(frame['payload']);
        final op = id == null ? null : _ops.remove(id);
        op?.controller.addError(ApitoError(message));
        op?.controller.close();
        if (_isAuthMessage(message)) {
          _failAuth();
        } else if (op != null && !op.localComplete) {
          _signals.add(const ApitoSubscriptionSignal(resyncRequired: true));
        }
      case 'complete':
        final id = frame['id']?.toString();
        final op = id == null ? null : _ops.remove(id);
        if (op == null) return;
        if (!op.localComplete) {
          _signals.add(const ApitoSubscriptionSignal(resyncRequired: true));
        }
        op.controller.close();
      case 'connection_error':
        final message = _errorText(frame['payload']);
        if (_isAuthMessage(message)) {
          _failAuth();
        } else {
          _scheduleRetry();
        }
    }
  }

  void _flush() {
    if (!_acked) return;
    for (final entry in _ops.entries) {
      final op = entry.value;
      if (op.sent) continue;
      op.sent = true;
      _send({
        'id': entry.key,
        'type': 'subscribe',
        'payload': {'query': op.document, 'variables': op.variables},
      });
    }
  }

  void _send(Map<String, dynamic> frame) {
    final socket = _socket;
    if (socket == null) return;
    try {
      socket.sink.add(jsonEncode(frame));
    } catch (_) {}
  }

  void _onSocketError(Object error) {
    if (_isAuthMessage('$error')) {
      _failAuth();
      return;
    }
    _scheduleRetry();
  }

  void _onSocketDone() {
    if (_disposed || !_foreground || _authFailed) return;
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (_disposed || !_foreground || _authFailed) return;
    _dropSocket();
    _setState(ApitoConnectionState.reconnecting);
    final cap = _config.subscriptionMaxBackoff.inMilliseconds;
    final base = _config.subscriptionInitialBackoff.inMilliseconds;
    final exp = base * (1 << _attempt.clamp(0, 16));
    final delayMs = min(cap, exp) + _random.nextInt(250);
    _attempt += 1;
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: delayMs), () {
      if (_ops.isNotEmpty) _ensureConnected();
    });
  }

  void _pausedClose() {
    _retry?.cancel();
    _dropSocket();
    _setState(ApitoConnectionState.idle);
  }

  void _failAuth() {
    _authFailed = true;
    onTokenExpired?.call();
    _dropSocket();
    for (final op in _ops.values) {
      op.controller.addError(ApitoError('Authentication failed', statusCode: 401));
      op.controller.close();
    }
    _ops.clear();
    _setState(ApitoConnectionState.closed);
  }

  void _dropSocket() {
    _acked = false;
    _ping?.cancel();
    _listener?.cancel();
    _listener = null;
    final socket = _socket;
    _socket = null;
    socket?.sink.close();
    for (final op in _ops.values) {
      op.sent = false;
    }
  }

  void _startPing() {
    _ping?.cancel();
    _ping = Timer.periodic(const Duration(seconds: 20), (_) {
      _send({'type': 'ping'});
    });
  }

  void _setState(ApitoConnectionState next) {
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }

  bool _hasCredential(Map<String, String> headers) {
    return (headers['Authorization'] ?? '').isNotEmpty ||
        (headers['X-Apito-Key'] ?? '').isNotEmpty;
  }

  bool _isAuthMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('unauthorized') ||
        lower.contains('forbidden') ||
        lower.contains('authentication') ||
        lower.contains('401') ||
        lower.contains('403');
  }

  String _errorText(dynamic payload) {
    if (payload is List) {
      return payload.map((e) => e is Map ? e['message'] : e).join('; ');
    }
    if (payload is Map && payload['message'] != null) return '${payload['message']}';
    return payload?.toString() ?? 'subscription error';
  }

}

class _LiveOp {
  _LiveOp(this.document, this.variables, this.controller);

  final String document;
  final Map<String, dynamic> variables;
  final StreamController<Map<String, dynamic>> controller;
  var sent = false;
  var localComplete = false;
}
