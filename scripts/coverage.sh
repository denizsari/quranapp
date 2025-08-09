#!/usr/bin/env bash
set -euo pipefail
flutter test --coverage
if command -v genhtml >/dev/null 2>&1; then
  genhtml coverage/lcov.info -o coverage/html >/dev/null 2>&1 || true
fi
LINES=$(grep -c 'end_of_record' coverage/lcov.info || echo 0)
echo "LCOV records: $LINES (see coverage/lcov.info)"
