import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_admin_sdk/src/codegen/operation_generator.dart';
import 'package:flutter_admin_sdk/src/codegen/provider_generator.dart';
import 'package:flutter_admin_sdk/src/codegen/schema_reader.dart';
import 'package:test/test.dart';

void main() {
  test('graphql-transport-ws multiplexes, cancels, and resyncs', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final sockets = <WebSocket>[];
    final frames = <Map<String, dynamic>>[];
    server.listen((request) async {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      expect(request.headers.value('x-apito-key'), 'ak_test');
      expect(request.headers.value('x-apito-project-id'), 'kisti');
      final socket = await WebSocketTransformer.upgrade(request, protocolSelector: (protocols) {
        expect(protocols, contains('graphql-transport-ws'));
        return 'graphql-transport-ws';
      });
      sockets.add(socket);
      socket.listen((raw) {
        final frame = Map<String, dynamic>.from(jsonDecode(raw as String) as Map);
        frames.add(frame);
        switch (frame['type']) {
          case 'connection_init':
            socket.add(jsonEncode({'type': 'connection_ack'}));
          case 'subscribe':
            socket.add(jsonEncode({
              'id': frame['id'],
              'type': 'next',
              'payload': {
                'data': {
                  'chatMessageChanged': {
                    'event': 'CREATED',
                    'model': 'chat_message',
                    'id': 'm1',
                    'projectId': 'kisti',
                    'node': {
                      'id': 'm1',
                      'data': {'thread_id': 't1', 'body': 'hi'},
                    },
                  },
                },
              },
            }));
          case 'ping':
            socket.add(jsonEncode({'type': 'pong'}));
        }
      });
    });

    final client = ApitoClient(
      config: ApitoConfig(
        endpoint: 'http://127.0.0.1:${server.port}/secured/graphql',
        apiKey: 'ak_test',
        projectId: 'kisti',
        subscriptionInitialBackoff: const Duration(milliseconds: 40),
        subscriptionMaxBackoff: const Duration(milliseconds: 80),
      ),
    );
    final signals = <ApitoSubscriptionSignal>[];
    final signalSub = client.subscriptionSignals.listen(signals.add);
    final first = <ModelChangeEvent>[];
    final second = <ModelChangeEvent>[];
    final a = client.modelChanges('chat_message', where: {
      'thread_id': {'eq': 't1'},
    }).listen(first.add);
    final b = client.modelChanges('chat_message', id: 'm1').listen(second.add);
    await _wait(() => first.isNotEmpty && second.isNotEmpty);
    expect(first.single.node?['data'], {'thread_id': 't1', 'body': 'hi'});
    expect(sockets, hasLength(1));
    expect(
      frames.where((frame) => frame['type'] == 'subscribe'),
      hasLength(2),
    );

    await a.cancel();
    await _wait(() => frames.any((frame) => frame['type'] == 'complete'));

    await sockets.single.close();
    await _wait(() => signals.any((signal) => signal.resyncRequired) && sockets.length > 1);

    await b.cancel();
    await signalSub.cancel();
    client.close();
    await server.close(force: true);
  });

  test('watch list snapshots, applies, and refetches on resync', () async {
    final changes = StreamController<ModelChangeEvent>();
    final resync = StreamController<void>();
    var snapshot = ['a'];
    final lists = apitoWatchList<String>(
      snapshot: () async => List<String>.from(snapshot),
      changes: changes.stream,
      resync: resync.stream,
      idOf: (item) => item,
      parse: (event) => event.id,
    );
    final seen = <List<String>>[];
    final sub = lists.listen(seen.add);
    await _wait(() => seen.isNotEmpty);
    changes.add(const ModelChangeEvent(
      event: ModelChangeKind.created,
      model: 'note',
      id: 'b',
      node: {'id': 'b'},
    ));
    await _wait(() => seen.last.length == 2);
    changes.add(const ModelChangeEvent(
      event: ModelChangeKind.deleted,
      model: 'note',
      id: 'a',
    ));
    await _wait(() => seen.last.join() == 'b');
    snapshot = ['z'];
    resync.add(null);
    await _wait(() => seen.last.join() == 'z');
    await sub.cancel();
    await changes.close();
    await resync.close();
  });

  test('codegen emits a changed subscription and a watch list', () {
    const model = ApitoSchemaModel(
      name: 'chat_message',
      fields: [ApitoSchemaField(name: 'body', graphqlType: 'String')],
    );
    final doc = const OperationGenerator().generateGraphqlFile(model);
    expect(doc, contains('subscription ChatMessageChanged'));
    expect(doc, contains('chatMessageChanged(events: \$events, id: \$id, where: \$where)'));
    final providers = const ProviderGenerator().generateProvidersFile(model);
    expect(providers, contains('watchChatMessageList'));
    expect(providers, contains('apitoWatchList<ChatMessage>'));
    expect(providers, isNot(contains('Timer')));
  });
}

Future<void> _wait(bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!ready()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
