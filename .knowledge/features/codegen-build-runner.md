---
type: feature
title: Codegen Build Runner
description: apito_codegen package and build_runner generators for models, ops, providers, where
resource: lib/apito_codegen.dart
tags: [flutter-admin-sdk, codegen, build_runner, dart]
timestamp: 2026-07-07T00:00:00Z
---

# Codegen Build Runner

## Purpose

Custom Dart codegen from Apito introspection JSON → models, GraphQL operations, where types, and Riverpod providers. Mirrors [introspection-codegen-pipeline](../../../../.knowledge/features/introspection-codegen-pipeline.md) for Flutter.

## Flows

- **Configure**: `build.yaml` + `@ApitoModel` annotations in consumer app.
- **Run**: `dart run build_runner build` triggers `ApitoBuilder`.
- **Input**: `example/apito_introspection.json` or live fetch per `CONTRACT.md`.
- **Output**: `lib/generated/` — models, operations, providers, where classes.

## Main files

- `lib/apito_codegen.dart` — codegen library export
- `lib/src/codegen/builder.dart` — build_runner entry
- `lib/src/codegen/model_generator.dart`
- `lib/src/codegen/operation_generator.dart`
- `lib/src/codegen/provider_generator.dart`
- `lib/src/codegen/where_generator.dart`
- `lib/src/codegen/schema_reader.dart`

## Dependencies

- [naming-engine](../../../../.knowledge/features/naming-engine.md)
- `build_runner`, `source_gen`
- Checked-in introspection snapshot

## Invariants

- Never hand-edit `lib/src/generated/` in consumer apps.
- Five ops per model — same as JS/Go codegen.
- Regenerate when `apito_introspection.json` changes.

## Common bugs

- build_runner cache stale — `dart run build_runner build --delete-conflicting-outputs`.
- Wrong introspection path in `build.yaml`.
- Partial codegen when `APITO_MODELS` filter excludes needed model.

## Tests

- Regenerate example app and run `flutter test`
- Naming vector parity with `test/fixtures/naming_vectors.json`

## Related

- [riverpod-providers-generated](riverpod-providers-generated.md)
- JS: [codegen-cli](../js-admin-sdk/.knowledge/features/codegen-cli.md)
- Global: [introspection-codegen-pipeline](../../../../.knowledge/features/introspection-codegen-pipeline.md)
