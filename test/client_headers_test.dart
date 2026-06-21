import 'package:flutter_admin_sdk/src/runtime/client.dart';
import 'package:flutter_admin_sdk/src/runtime/config.dart';
import 'package:test/test.dart';

void main() {
  test('buildHeaders sends project id and ak token like JS SDK', () {
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/secured/graphql',
        apiKey: 'ak_session',
        projectId: 'kisti_gkrml',
        tenantId: 'tenant_1',
      ),
    );

    expect(client.buildHeaders(), {
      'Content-Type': 'application/json',
      'X-Apito-Key': 'ak_session',
      'X-Apito-Tenant-ID': 'tenant_1',
      'X-Apito-Project-ID': 'kisti_gkrml',
    });
    client.close();
  });
}
