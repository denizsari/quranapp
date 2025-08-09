#!/usr/bin/env bash
set -euo pipefail

CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.dart$' || true)

if [ -z "${CHANGED}" ]; then
  echo "No staged dart files."; exit 0
fi

echo "Formatting Dart files (dart format)..."
dart format --set-exit-if-changed ${CHANGED} || {
  echo "Re-formatting (writing changes)";
  dart format ${CHANGED};
}

echo "Running analyzer..."
dart analyze || { echo "Analyzer failed"; exit 1; }

echo "Running unit tests (fast subset)..."
flutter test test/progression_test.dart test/spaced_repetition_test.dart

echo "All pre-commit checks passed. Adding formatted files..."
git add ${CHANGED}
