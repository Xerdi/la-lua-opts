#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

out=$(mktemp)
trap 'rm -f "$out"' EXIT

if ! la-lua-opts -o build --final final-example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi
