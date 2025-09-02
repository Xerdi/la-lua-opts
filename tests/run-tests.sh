#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# Basic test runner; each test_xxx.sh returns 0 on success
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

pass=0
fail=0

echo "Running la-lua-opts test suite..."
for t in tests/test_*.sh tests/*/test_*.sh; do
  echo "- $(basename "$t")"
  if bash "$t"; then
    echo "  PASS"
    pass=$((pass+1))
  else
    echo "  FAIL"
    fail=$((fail+1))
  fi
done

echo "Summary: ${pass} passed, ${fail} failed"
[ "$fail" -eq 0 ]
