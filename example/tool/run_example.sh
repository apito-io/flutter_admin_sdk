#!/usr/bin/env bash
# Run demo; runs build_runner first if generated code is missing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f secrets.env ]]; then
  echo "Create secrets.env from secrets.env.example"
  exit 1
fi

if [[ ! -f lib/generated/models/loan.dart ]]; then
  echo "Generated code missing — run: dart run build_runner build"
  dart pub get
  dart run build_runner build --delete-conflicting-outputs
fi

set -a
# shellcheck disable=SC1091
source secrets.env
set +a

dart pub get
dart run \
  --define=APITO_GRAPHQL_ENDPOINT="${APITO_GRAPHQL_ENDPOINT}" \
  --define=APITO_API_KEY="${APITO_API_KEY}" \
  --define=APITO_TENANT_ID="${APITO_TENANT_ID}" \
  lib/main.dart
