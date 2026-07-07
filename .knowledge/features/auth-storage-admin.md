---
type: feature
title: Auth Storage Admin
description: Token storage, auth helpers, and admin REST operations in Flutter SDK
resource: lib/src/runtime/auth.dart
tags: [flutter-admin-sdk, auth, storage, admin]
timestamp: 2026-07-07T00:00:00Z
---

# Auth Storage Admin

## Purpose

Flutter-side auth persistence and admin API helpers aligned with [auth-tenant-admin](../../../../.knowledge/features/auth-tenant-admin.md). Complements `ApitoClient` with secure token storage and REST utilities.

## Flows

- **Login**: auth helpers post login mutation, store bearer in secure storage.
- **Persist**: `storage.dart` read/write token, tenant id, project id.
- **Logout**: clear storage + reset client config.
- **REST**: `rest.dart` secured file upload/list/delete (see global secured-files doc).
- **Admin**: tenant/user operations via GraphQL documents from codegen.

## Main files

- `lib/src/runtime/auth.dart` — login/session helpers
- `lib/src/runtime/storage.dart` — token persistence abstraction
- `lib/src/runtime/storage_paths.dart` — storage key constants
- `lib/src/runtime/rest.dart` — REST file + admin calls
- `lib/src/runtime/admin_models.dart` — user/tenant model classes

## Dependencies

- Global: [auth-tenant-admin](../../../../.knowledge/features/auth-tenant-admin.md), [secured-files-rest](../../../../.knowledge/features/secured-files-rest.md)
- `flutter_secure_storage` or consumer-provided storage adapter

## Invariants

- Never store API keys in plain `SharedPreferences` for production apps.
- Refresh `ApitoConfig.authToken` after login before model providers fetch.
- Google / tenant admin ops respect Workers v1 limits per `CONTRACT.md`.

## Common bugs

- Token restored on startup but `ApitoClient` still uses old config instance.
- Missing tenant id in storage for SaaS multi-tenant apps.
- REST calls without updated bearer after login.

## Tests

- Unit tests for storage read/write round-trip
- Manual login flow in `example/` app

## Related

- [apito-client-query-builder](apito-client-query-builder.md)
- Global: [auth-tenant-admin](../../../../.knowledge/features/auth-tenant-admin.md)
