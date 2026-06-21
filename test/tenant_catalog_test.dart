import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('tenant catalog validation', () {
    final client = ApitoClient(
      config: ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'test-key',
      ),
    );

    test('createTenant requires name', () async {
      expect(
        client.createTenant(const CreateTenantParams(name: '')),
        throwsA(isA<ApitoError>()),
      );
    });

    test('updateTenant requires tenantId', () async {
      expect(
        client.updateTenant('', const UpdateTenantParams(name: 'x')),
        throwsA(isA<ApitoError>()),
      );
    });

    test('deleteTenant requires tenantId', () async {
      expect(
        client.deleteTenant(''),
        throwsA(isA<ApitoError>()),
      );
    });
  });
}
