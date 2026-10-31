import 'package:web_socket_channel/web_socket_channel.dart';

import 'subscription_socket_stub.dart'
    if (dart.library.io) 'subscription_socket_io.dart'
    if (dart.library.html) 'subscription_socket_web.dart';

/// True when the platform cannot set WebSocket handshake headers.
bool get subscriptionAuthUsesTicket => subscriptionPlatformUsesTicket;

Future<WebSocketChannel> connectSubscriptionSocket({
  required Uri uri,
  required Map<String, String> headers,
  required List<String> protocols,
}) {
  return connectPlatformSubscriptionSocket(
    uri: uri,
    headers: headers,
    protocols: protocols,
  );
}
