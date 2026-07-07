---
type: feature
title: Filters Where Clauses
description: Dart filter variables, where generators, and relation/connection list scopes
resource: lib/src/runtime/filter_variables.dart
tags: [flutter-admin-sdk, filters, where, list]
timestamp: 2026-07-07T00:00:00Z
---

# Filters Where Clauses

## Purpose

Flutter implementation of list filter semantics — link [list-filters-and-relations](../../../../.knowledge/features/list-filters-and-relations.md), do not duplicate operator tables. Builds GraphQL `where`, `sort`, pagination, relation, and connection inputs.

## Flows

- **List vars**: `buildFilterVariables` / `FilterVariables` → query builder args.
- **Relation**: `list_relation_filters.dart` — eq filters on related models.
- **Connection**: `list_connection_filters.dart` — HasMany count/sort sub-filters.
- **Codegen**: `where_generator.dart` emits per-model where input helpers in `generated/`.

## Main files

- `lib/src/runtime/filter_variables.dart`
- `lib/src/runtime/filter.dart`, `crud_filter.dart`
- `lib/src/runtime/list_relation_filters.dart`
- `lib/src/runtime/list_connection_filters.dart`
- `lib/src/generated/base_where.dart` — generated where types
- `lib/src/codegen/where_generator.dart`

## Dependencies

- [naming-engine](../../../../.knowledge/features/naming-engine.md)
- Global: [list-filters-and-relations](../../../../.knowledge/features/list-filters-and-relations.md)
- JS reference: `js-admin-sdk` [filter-variables-builder](../js-admin-sdk/.knowledge/features/filter-variables-builder.md)

## Invariants

- Filter operators must match JS SDK mapping — parity tested via `naming_vectors.json`.
- Generated where types are regenerated, not hand-edited.
- Relation filters require schema connection metadata.

## Common bugs

- Using string where maps instead of typed where classes → runtime GraphQL errors.
- Connection count filter on wrong relation key.
- Sort field name not resolved through naming helpers.

## Tests

- Compare behavior with JS `buildListQueryVariables.test.ts` vectors
- `test/fixtures/naming_vectors.json` shared with Go/JS

## Related

- [apito-client-query-builder](apito-client-query-builder.md), [sdk-sync-parity](sdk-sync-parity.md)
- Global: [list-filters-and-relations](../../../../.knowledge/features/list-filters-and-relations.md)
