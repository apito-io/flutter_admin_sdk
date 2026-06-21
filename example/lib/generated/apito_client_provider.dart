// Wire this provider in your app (endpoint + API key from env/config).
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apito_client_provider.g.dart';

@Riverpod(keepAlive: true)
ApitoClient apitoClient(Ref ref) {
  throw UnimplementedError(
    'Override apitoClientProvider with your ApitoConfig endpoint and API key.',
  );
}
