---
type: feature
title: Riverpod Providers Generated
description: Generated Riverpod providers wrapping per-model list, one, and mutation operations
resource: lib/src/generated/base_provider.dart
tags: [flutter-admin-sdk, riverpod, providers, generated]
timestamp: 2026-07-07T00:00:00Z
---

# Riverpod Providers Generated

## Purpose

Codegen emits Riverpod providers per model for Flutter admin apps — parallel to JS TanStack React Query hooks. Wires [apito-client-query-builder](apito-client-query-builder.md) into reactive UI state.

## Flows

- **List provider**: watch paginated list with filter args.
- **Detail provider**: `family` by id for get-one.
- **Mutations**: create/update/delete providers invalidate list providers.
- **Base**: `base_provider.dart` shared notifier patterns in generated output.

## Main files

- `lib/src/generated/base_provider.dart` — generated base (template)
- `lib/src/codegen/provider_generator.dart` — provider codegen
- Consumer `lib/generated/*_provider.dart` — per-model output
- `lib/src/runtime/mutation_builder.dart` — mutation document helper

## Dependencies

- [codegen-build-runner](codegen-build-runner.md)
- `flutter_riverpod` in consumer apps
- [filters-where-clauses](filters-where-clauses.md) for list provider args

## Invariants

- Providers generated — do not copy-paste provider code into apps.
- Invalidation keys must include model name + filter hash for list refresh.
- Use generated provider names from codegen, not ad-hoc `Provider` wrappers.

## Common bugs

- Stale list after mutation — missing ref.invalidate on generated list provider.
- Passing non-serializable filter objects into provider families.
- Provider read before `ApitoClient` override in `ProviderScope`.

## Tests

- Example app widget tests with `ProviderContainer`
- Compare invalidation behavior with JS `queryInvalidation.ts`

## Related

- [apito-client-query-builder](apito-client-query-builder.md)
- JS: [react-headless-hooks](../js-admin-sdk/.knowledge/features/react-headless-hooks.md)
