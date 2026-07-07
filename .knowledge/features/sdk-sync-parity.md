---
type: feature
title: SDK Sync Parity
description: Cross-SDK naming and filter parity enforced via shared vectors and CONTRACT
resource: lib/src/runtime/naming.dart
tags: [flutter-admin-sdk, parity, contract, naming]
timestamp: 2026-07-07T00:00:00Z
---

# SDK Sync Parity

## Purpose

Flutter SDK stays aligned with JS and Go admin SDKs via shared `naming_vectors.json`, `CONTRACT.md`, and `SYNC_SUMMARY.md`. Dart `naming.dart` is a reference implementation alongside TS and Go.

## Flows

- **Vectors**: copy `test/fixtures/naming_vectors.json` verbatim from canonical source when syncing.
- **Naming**: type names, field keys, operation names must match [naming-engine](../../../../.knowledge/features/naming-engine.md).
- **Filters**: where/sort semantics match JS [filter-variables-builder](../js-admin-sdk/.knowledge/features/filter-variables-builder.md).
- **Release**: bump `version.dart` with JS/Go when contract changes.

## Main files

- `lib/src/runtime/naming.dart` — Dart naming engine
- `test/fixtures/naming_vectors.json` — golden vectors
- `SYNC_SUMMARY.md` (go-admin-sdk) — cross-SDK changelog
- `CONTRACT.md` (go-admin-sdk) — shared contract doc

## Dependencies

- [naming-engine](../../../../.knowledge/features/naming-engine.md)
- [admin-sdk-contract](../../../../.knowledge/features/admin-sdk-contract.md)
- Coordinated releases across `sdk/*` repos

## Invariants

- Any naming change requires updating all three SDKs + vectors in same PR wave.
- Do not fork naming rules per language — engine is single source of truth.
- Introspection snapshots should be refreshed together across SDK test fixtures.

## Common bugs

- Drift when only one SDK regenerated after schema change.
- Local naming hack in app instead of fixing SDK vector.
- Assuming camelCase GraphQL names — Apito uses composed naming vectors.

## Tests

- Naming unit tests against `naming_vectors.json`
- Cross-check with `js-admin-sdk` `naming.test.ts` and Go `naming_test.go`

## Related

- [filters-where-clauses](filters-where-clauses.md), [codegen-build-runner](codegen-build-runner.md)
- Global: [naming-engine](../../../../.knowledge/features/naming-engine.md), [admin-sdk-contract](../../../../.knowledge/features/admin-sdk-contract.md)
