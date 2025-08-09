#!/usr/bin/env bash
set -euo pipefail
flutter test --coverage
if command -v genhtml >/dev/null 2>&1; then
  genhtml coverage/lcov.info -o coverage/html >/dev/null 2>&1 || true
fi
LINES=$(grep -c 'end_of_record' coverage/lcov.info || echo 0)
echo "LCOV records: $LINES (see coverage/lcov.info)"

# Simple line coverage percentage extraction (Dart format) and gate.
if command -v awk >/dev/null 2>&1; then
  TOTAL=$(grep -E 'SF:' -c coverage/lcov.info || echo 0)
  # Approximate: count of DA: lines vs covered DA:.*,[1-9]
  DA_TOTAL=$(grep -c 'DA:' coverage/lcov.info || echo 0)
  DA_HIT=$(grep 'DA:' coverage/lcov.info | grep -E ',[1-9][0-9]*' | wc -l | tr -d ' ')
  if [ "$DA_TOTAL" -gt 0 ]; then
    PCT=$(awk -v h=$DA_HIT -v t=$DA_TOTAL 'BEGIN { printf("%.2f", (h/t)*100) }')
    echo "Approx line coverage: $PCT%"
  THRESHOLD=${COVERAGE_MIN:-45}
  if awk -v p=$PCT -v th=$THRESHOLD 'BEGIN { exit (p+0 >= th) ? 0 : 1 }'; then
      echo "Coverage gate passed (>=${THRESHOLD}%)."
    else
      echo "Coverage gate FAILED (<${THRESHOLD}%)." >&2
      exit 1
    fi
  fi
fi
