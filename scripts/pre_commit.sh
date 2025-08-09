#!/usr/bin/env bash
set -euo pipefail

CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(dart)
?$' || true)

if [ -z "${CHANGED}" ]; then
  echo "No staged dart files."; exit 0
fi

echo "Formatting Dart files..."
flutter format ${CHANGED}

echo "Running analyzer..."
flutter analyze ${CHANGED}

echo "Running unit tests (fast subset)..."
flutter test test/progression_test.dart test/spaced_repetition_test.dart

echo "All pre-commit checks passed. Adding formatted files..."
git add ${CHANGED}
