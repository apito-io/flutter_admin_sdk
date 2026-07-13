# Flutter Admin SDK — Cross-SDK Sync Summary

**Package:** `flutter_admin_sdk` (v0.6.4)  
**Aligned with:** `js-admin-sdk` v3.8.0, `go-admin-sdk` v2.6.3

## Shared contract

See [CONTRACT.md](CONTRACT.md) for naming vectors, introspection snapshot locations, 5-operation doc format, admin client surface, and codegen outputs.

## v0.6.4 (2026-07-13)

- **`searchTenants`** — paginated catalog search + `SearchTenantsResponse`; full tenant catalog surface documented (`getTenants`, CRUD, `searchTenantsByDomain`)
- **Tenant user-parity** — catalog lifecycle is system GraphQL only (not secured `tenant` model CRUD)

## v0.6.3 (2026-07-11)

- **`searchUsers` optional `q`** — named param filters email, username, phone, or id

## v0.6.1 (2026-07-05)

- **List relation filters** — `relationEq`, `CrudFilter` / `RelationCrudFilter`, codegen `RelationKeys` + connect factories; list providers accept `relationFilters`
- **Cloudflare Workers v1** — document `generateTenantToken` / tenant catalog and Google `loginUser` limitations on Workers; password `loginUser` unchanged

## v0.6.0 (2026-06-21)

- **Riverpod provider codegen** — `generate_providers: true`, media-safe query fields, mutation invalidation guards

## v0.5.0 (2026-06-11)

- **`tenantId` on user CRUD** — `searchUsers`, `createUser`, `updateUser` pass optional GraphQL `tenant_id` (pro SaaS)

## v0.4.0 (2026-06-08)

- **`loginUser` `tenantId`** — optional GraphQL `tenant_id`; required for SaaS per-tenant separate DB projects

## v0.2.0 (2026-06-05)

- Renamed package `flutter_apito_sdk` → `flutter_admin_sdk` (backward export retained)
- Added **storage** REST: `uploadFile`, `listFiles`, `deleteFiles`
- Added **auth/admin** GraphQL: `generateTenantToken`, `getTenants`, `searchTenants`, `createTenant`, `updateTenant`, `deleteTenant`, `loginUser`, `googleOAuthState`, `searchUsers`, `searchTenantsByDomain`, `createUser`, `updateUser`, `resetUserPassword`, `deleteUser`
- Added `restBaseUrl` to `ApitoConfig`, `X-Apito-Sync-Key` for cli/sdk keys
- Canonical `test/fixtures/naming_vectors.json` (17 vectors, shared with JS/Go)
- Codegen emits `schema.graphql` SDL alongside operations
- Operation contract locked by `test/operation_contract_test.dart`

## Sync process

When JS or Go admin SDK changes admin surface or naming:

1. Update Dart `auth.dart` / `storage.dart` to match
2. Copy `naming_vectors.json` if vectors change
3. Bump version line across all three SDKs
4. Run parity tests in each repo
