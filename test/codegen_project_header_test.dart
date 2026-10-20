import 'dart:convert';

import 'package:flutter_admin_sdk/src/codegen/schema_reader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('secured introspection sends X-Apito-Project-Id', () async {
    late http.Request captured;
    final reader = SchemaReader(
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              '__schema': {
                'queryType': {'name': 'Query', 'fields': <Map<String, dynamic>>[]},
                'types': <Map<String, dynamic>>[],
              },
            },
          }),
          200,
        );
      }),
    );

    await reader.fetchFromEndpoint(
      endpoint: 'http://localhost:5050/secured/graphql',
      apiKey: 'apt_test',
      projectId: 'kisti_gkrml',
      tenantId: 'tenant_1',
    );

    expect(captured.headers['authorization'], 'Bearer apt_test');
    expect(captured.headers.containsKey('x-apito-key'), isFalse);
    expect(captured.headers['x-apito-project-id'], 'kisti_gkrml');
    expect(captured.headers['x-apito-tenant-id'], 'tenant_1');
  });
}
