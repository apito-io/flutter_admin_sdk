#!/usr/bin/env bash
# Optional CI drift check — compares canonical naming_vectors.json across SDK repos.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANON="$ROOT/test/fixtures/naming_vectors.json"
JS="${JS_ADMIN_SDK_PATH:-$HOME/go/src/gitlab.com/apito.io/js-admin-sdk}/test/fixtures/naming_vectors.json"
GO="${GO_ADMIN_SDK_PATH:-$HOME/go/src/gitlab.com/apito.io/go-admin-sdk}/test/fixtures/naming_vectors.json"

fail=0
for f in "$JS" "$GO"; do
  if [[ ! -f "$f" ]]; then
    echo "SKIP missing $f"
    continue
  fi
  if ! diff -q "$CANON" "$f" >/dev/null; then
    echo "DRIFT: $f differs from $CANON"
    fail=1
  else
    echo "OK $f"
  fi
done
exit $fail
