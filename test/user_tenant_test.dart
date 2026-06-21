import 'dart:convert';

import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _CapturingHttpClient extends http.BaseClient {
  String? lastBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      lastBody = request.body;
    } else {
      final bytes = await request.finalize().toBytes();
      lastBody = utf8.decode(bytes);
    }
    final responseBody = jsonEncode({
      'data': {
        'searchUsers': {'count': 0, 'users': []},
        'createUser': {'id': 'u1', 'role': 'none', 'tenant_id': 't1'},
        'updateUser': {'id': 'u1', 'role': 'vendor', 'tenant_id': 't1'},
      },
    });
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  group('user CRUD tenantId', () {
    late _CapturingHttpClient httpClient;
    late ApitoClient client;

    setUp(() {
      httpClient = _CapturingHttpClient();
      client = ApitoClient(
        config: const ApitoConfig(
          endpoint: 'http://localhost:5050/system/graphql',
          apiKey: 'test-key',
        ),
        httpClient: httpClient,
      );
    });

    tearDown(() => client.close());

    test('CreateUserParams and UpdateUserParams accept tenantId', () {
      const create = CreateUserParams(
        password: 'secret',
        email: 'a@b.com',
        tenantId: 'tenant-1',
      );
      const update = UpdateUserParams(tenantId: 'tenant-1');
      expect(create.tenantId, 'tenant-1');
      expect(update.tenantId, 'tenant-1');
    });

    test('searchUsers sends tenant_id when tenantId is set', () async {
      await client.searchUsers('proj', limit: 10, tenantId: 'tenant-abc');
      final payload = jsonDecode(httpClient.lastBody!) as Map<String, dynamic>;
      final vars = payload['variables'] as Map<String, dynamic>;
      expect(vars['tenant_id'], 'tenant-abc');
      expect(payload['query'], contains('tenant_id'));
    });

    test('createUser sends tenant_id from params.tenantId', () async {
      await client.createUser(
        'proj',
        const CreateUserParams(
          password: 'secret',
          email: 'a@b.com',
          tenantId: 'tenant-xyz',
        ),
      );
      final payload = jsonDecode(httpClient.lastBody!) as Map<String, dynamic>;
      final vars = payload['variables'] as Map<String, dynamic>;
      expect(vars['tenant_id'], 'tenant-xyz');
    });

    test('updateUser sends tenant_id from params.tenantId', () async {
      await client.updateUser(
        'u1',
        const UpdateUserParams(tenantId: 'tenant-xyz'),
      );
      final payload = jsonDecode(httpClient.lastBody!) as Map<String, dynamic>;
      final vars = payload['variables'] as Map<String, dynamic>;
      expect(vars['tenant_id'], 'tenant-xyz');
    });

    test('updateUser requires at least one field', () async {
      expect(
        client.updateUser('u1', const UpdateUserParams()),
        throwsA(isA<ApitoError>()),
      );
    });
  });
}
