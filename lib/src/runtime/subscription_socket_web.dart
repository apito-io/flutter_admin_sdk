import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const bool subscriptionPlatformUsesTicket = true;

Future<WebSocketChannel> connectPlatformSubscriptionSocket({
  required Uri uri,
  required Map<String, String> headers,
  required List<String> protocols,
}) async {
  // Browsers cannot set handshake headers. Auth travels as a one-time ticket
  // subprotocol added by the client before this call. Cookies still ride along.
  return HtmlWebSocketChannel.connect(uri, protocols: protocols);
}
