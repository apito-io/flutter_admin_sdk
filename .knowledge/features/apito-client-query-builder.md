---
type: feature
title: Apito Client Query Builder
description: Flutter ApitoClient and chainable QueryBuilder for GraphQL model operations
resource: lib/src/runtime/client.dart
tags: [flutter-admin-sdk, dart, client, graphql]
timestamp: 2026-07-07T00:00:00Z
---

# Apito Client Query Builder

## Purpose

Dart entry point for [admin-sdk-contract](../../../../.knowledge/features/admin-sdk-contract.md). `ApitoClient` posts GraphQL with Apito auth headers; `QueryBuilder` chains list/get/create/update/delete per model.

## Flows

- **Setup**: `ApitoClient(config: ApitoConfig(baseUrl, apiKey, tenantId?, projectId?))`.
- **Chain**: `client.from('loan').list(where: …).execute()`.
- **Headers**: `buildHeaders()` — bearer, `X-Apito-Key`, tenant/project ids.
- **Token expiry**: optional `onTokenExpired` callback for refresh flows.

## Main files

- `lib/src/runtime/client.dart` — `ApitoClient`, `execute`
- `lib/src/runtime/query_builder.dart` — fluent query builder
- `lib/src/runtime/config.dart` — `ApitoConfig`
- `lib/src/runtime/document_builder.dart` — GraphQL document assembly
- `lib/flutter_admin_sdk.dart` — public exports

## Dependencies

- `package:http` for GraphQL POST
- [naming-engine](../../../../.knowledge/features/naming-engine.md) via `naming.dart`

## Invariants

- Model names passed to `from()` match schema model keys (snake_case / engine convention).
- Auth header rules mirror JS/Go (`cli-`/`sdk-` → sync key).
- Do not construct raw GraphQL strings in apps — use builder + generated ops.

## Common bugs

- `onTokenExpired` not wired — silent 401 on expired bearer.
- Wrong `baseUrl` (system vs public endpoint).
- Missing `projectId` header when engine requires it.

## Tests

- `test/` runtime client tests (if present)
- Example app integration under `example/`

## Related

- [filters-where-clauses](filters-where-clauses.md), [riverpod-providers-generated](riverpod-providers-generated.md)
- Global: [admin-sdk-contract](../../../../.knowledge/features/admin-sdk-contract.md)
