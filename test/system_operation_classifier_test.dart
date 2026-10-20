import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('bootstrap credentials reject an aliased privileged root field',
      () async {
    var calls = 0;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'ak_bootstrap',
      ),
      httpClient: MockClient((_) async {
        calls++;
        return http.Response('{"data":{}}', 200);
      }),
    );

    await expectLater(
      () => client.execute(
        r'query { harmless: createTenant(name: "x") { id } }',
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(calls, 0);
    client.close();
  });

  test('bootstrap credentials resolve privileged fields through fragments',
      () async {
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'ak_bootstrap',
      ),
    );

    const documents = [
      r'''
        query Read {
          ...TenantMutation
        }
        fragment TenantMutation on Query {
          createTenant(name: "x") { id }
        }
      ''',
      r'''
        query Read {
          ... on Query {
            deleteTenant(tenant_id: "x")
          }
        }
      ''',
      r'''
        query One { searchTenantsByDomain(domain: "deleteTenant") { tenant { id } } }
        mutation Two { updateTenant(tenant_id: "x", name: "y") { id } }
      ''',
    ];

    for (final document in documents) {
      await expectLater(
        () => client.execute(document),
        throwsA(isA<ArgumentError>()),
      );
    }
    client.close();
  });

  test('classifier ignores comments, strings, arguments, and nested fields',
      () async {
    var calls = 0;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'ak_bootstrap',
      ),
      httpClient: MockClient((request) async {
        calls++;
        expect(request.body, contains('searchTenantsByDomain'));
        return http.Response('{"data":{"ok":true}}', 200);
      }),
    );

    final data = await client.execute(r'''
      # createTenant must not be found in a comment
      query Safe($needle: String = "deleteTenant") @include(if: true) {
        searchTenantsByDomain(domain: $needle) {
          tenant { id }
        }
        nested {
          createTenant
        }
      }
    ''');

    expect(data['ok'], isTrue);
    expect(calls, 1);
    client.close();
  });

  test('malformed or cyclic documents fail closed for bootstrap credentials',
      () async {
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'ak_bootstrap',
      ),
    );

    for (final document in [
      'query {',
      r'''
        query Read { ...A }
        fragment A on Query { ...B }
        fragment B on Query { ...A }
      ''',
    ]) {
      await expectLater(
        () => client.execute(document),
        throwsA(isA<ArgumentError>()),
      );
    }
    client.close();
  });

  test('apt operator credential may send a privileged document', () async {
    var calls = 0;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: '',
        accessToken: 'apt_operator',
      ),
      httpClient: MockClient((_) async {
        calls++;
        return http.Response('{"data":{"ok":true}}', 200);
      }),
    );

    final data = await client.execute(
      r'query { x: createTenant(name: "x") { id } }',
    );
    expect(data['ok'], isTrue);
    expect(calls, 1);
    client.close();
  });

  test('secured GraphQL does not use the system-plane classifier', () async {
    var calls = 0;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/secured/graphql',
        apiKey: 'ak_app_user',
      ),
      httpClient: MockClient((request) async {
        calls++;
        expect(request.headers['X-Apito-Key'], 'ak_app_user');
        return http.Response('{"data":{"ok":true}}', 200);
      }),
    );

    final data = await client.execute(
      r'mutation { createTenant(name: "x") { id } }',
    );

    expect(data['ok'], isTrue);
    expect(calls, 1);
    client.close();
  });

  test(
      'privileged convenience methods reject bootstrap credentials before HTTP',
      () async {
    var calls = 0;
    final client = ApitoClient(
      config: const ApitoConfig(
        endpoint: 'http://localhost:5050/system/graphql',
        apiKey: 'ak_bootstrap',
      ),
      httpClient: MockClient((_) async {
        calls++;
        return http.Response('{"data":{}}', 200);
      }),
    );

    await expectLater(
      () => client.createUser(
        'project',
        const CreateUserParams(password: 'password'),
      ),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      () => client.listProjectPlans(),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      () => client.verifyProjectPayment(
        const VerifyProjectPaymentParams(
          projectId: 'project',
          tenantId: 'tenant',
          productId: 'product',
          purchaseToken: 'purchase',
          packageName: 'package',
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(calls, 0);
    client.close();
  });
}
