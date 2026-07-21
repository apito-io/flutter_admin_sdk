import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      'X-Apito-Project-Id': 'kisti_gkrml',
    });
    client.close();
  });

  test('buildHeaders sends apt_ access tokens as Bearer only (no dual header)',
      () {
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: '',
        accessToken: 'apt_user_tok_secret',
        projectId: 'proj1',
      ),
    );

    final headers = client.buildHeaders();
    expect(headers['Authorization'], 'Bearer apt_user_tok_secret');
    expect(headers['X-Use-Cookies'], 'false');
    expect(headers['X-Apito-Project-Id'], 'proj1');
    expect(headers.containsKey('X-Apito-Key'), isFalse);
    expect(headers.containsKey('X-Apito-Sync-Key'), isFalse);
    client.close();
  });

  test('explicit project method overrides configured project header', () async {
    late http.Request captured;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: '',
        accessToken: 'apt_user_tok_secret',
        projectId: 'project-config',
      ),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          '{"data":{"searchUsers":{"count":0,"users":[]}}}',
          200,
        );
      }),
    );

    await client.searchUsers('project-method', tenantId: 'tenant-method');

    expect(captured.headers['X-Apito-Project-Id'], 'project-method');
    expect(captured.headers['X-Apito-Tenant-ID'], 'tenant-method');
    client.close();
  });

  test('buildHeaders rejects retired cli-/sdk-/mcp- token prefixes', () {
    for (final prefix in ['cli-', 'sdk-', 'mcp-']) {
      final client = ApitoClient(
        config: ApitoConfig(
          endpoint: 'http://localhost:5050/system/graphql',
          apiKey: '${prefix}legacy',
        ),
      );
      expect(
        client.buildHeaders,
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('TOKEN_FORMAT_RETIRED'),
        )),
      );
      client.close();
    }
  });
}
