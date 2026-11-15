#!/usr/bin/env bash
# Runs the same checks as CI, one section per technology: Dart packages (format, analysis, tests), then the
# TypeScript tests. Needs Flutter and Node 22+ on the PATH. SQL tests: see sql/README.md.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== dart"
for dir in dart/packages/*/; do
  echo "== $dir"
  (
    cd "$dir"
    flutter pub get >/dev/null
    dart format --output=none --set-exit-if-changed .
    flutter analyze
    flutter test
  )
done

echo "== typescript"
node --experimental-strip-types --test typescript/edge-functions/edge_functions_test.ts
echo "All checks passed."
