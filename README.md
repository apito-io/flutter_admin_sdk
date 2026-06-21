# Flutter Admin SDK

Admin Apito SDK for Flutter — chainable secured GraphQL, REST storage, auth/admin, plus schema-driven codegen (typed models, Where filters, Riverpod providers). Aligned with `js-admin-sdk` and `go-admin-sdk` (see [CONTRACT.md](CONTRACT.md), [SYNC_SUMMARY.md](SYNC_SUMMARY.md)).

## Runtime (no codegen)

```dart
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

final client = ApitoClient(
  config: ApitoConfig(
    endpoint: 'http://localhost:5050/secured/graphql',
    apiKey: 'your-key',
    tenantId: 'tenant-id',
  ),
);

final loans = await client
    .from('loan')
    .select(['loan_id', 'total_amount'])
    .where({'vendor_id': Eq(vendorId)})
    .page(1)
    .limit(50)
    .sort('created_at', descending: true)
    .list();
```

System GraphQL fallback (`getModelData` / `upsertModelData`) is available via `listModelSystem` and `upsertModelSystem` on `ApitoClient`.

## Storage & auth (admin parity)

```dart
// Files (REST)
final file = await client.uploadFile(UploadFileParams(fileName: 'doc.pdf', content: bytes));
final listing = await client.listFiles(limit: 50);

// Users / tenants (system GraphQL). Google login may link verified email to an existing user.
final token = await client.generateTenantToken(tenantId);
final session = await client.loginUser(LoginUserParams(
  projectId: '...',
  tenantId: 'catalog-tenant-id', // required for SaaS per-tenant separate DB
  password: '...',
  email: '...',
));

// Pro SaaS user admin — pass tenantId on search/create/update (GraphQL tenant_id)
final users = await client.searchUsers('...', tenantId: 'catalog-tenant-id');
final user = await client.createUser(
  '...',
  CreateUserParams(
    password: '...',
    email: '...',
    tenantId: 'catalog-tenant-id',
  ),
);
await client.updateUser('user-id', UpdateUserParams(tenantId: 'catalog-tenant-id'));
```

## Code generation (`build.yaml` only)

Add `apito_schema.json` (trigger file) and configure **`build.yaml`**:

```yaml
targets:
  $default:
    sources:
      include:
        - apito_schema.json
        - lib/**
        - pubspec.yaml
        - build.yaml
        - $package$
    builders:
      flutter_admin_sdk|apito_generator:
        enabled: true
        generate_for:
          - apito_schema.json
        options:
          endpoint: http://localhost:5050/secured/graphql
          api_key_env: APITO_API_KEY
          tenant_id_env: APITO_TENANT_ID
          secrets_file: secrets.env
          schema_file: apito_schema.json
          output: lib/generated
          generate_providers: true
          generate_where: true
          generate_operations: true
```

```bash
# secrets.env: APITO_API_KEY=... APITO_TENANT_ID=...
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

Then run `dart run build_runner build` again in your app for `@riverpod` `.g.dart` files if `generate_providers: true`.

## Example

See [`example/`](example/) — same `build.yaml` flow, then `dart run lib/main.dart`.

## Package layout

- `lib/flutter_admin_sdk.dart` — runtime
- `lib/apito_codegen.dart` — codegen types (used by the builder)
- `build.yaml` — registers `apito_generator` for consuming apps
- `example/` — demo app
