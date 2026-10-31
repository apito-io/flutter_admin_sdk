import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const bool subscriptionPlatformUsesTicket = false;

Future<WebSocketChannel> connectPlatformSubscriptionSocket({
  required Uri uri,
  required Map<String, String> headers,
  required List<String> protocols,
}) async {
  return IOWebSocketChannel.connect(
    uri,
    headers: headers,
    protocols: protocols,
  );
}
