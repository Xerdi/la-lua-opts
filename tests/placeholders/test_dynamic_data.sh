#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

out=$(mktemp)
trap 'rm -f "$out"' EXIT

if ! la-lua-opts -o build --recipe=example:example-recipe.yaml example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi

# Check that the recipe loading info message is present in the output
if ! grep -F "Info: loading recipe 'example-recipe.yaml' for namespace 'example'." "$out" >/dev/null; then
  echo "Expected info message not found in output" >&2
  echo "--- Begin output ---" >&2
  sed -n '1,200p' "$out" >&2 || true
  echo "--- End output ---" >&2
  exit 1
fi


if ! la-lua-opts -o build --recipe=example:example-recipe.yaml --payload=example:example-payload.yaml example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi

# Check that the payload loading info message is present in the output
if ! grep -F "Info: loading payload 'example-payload.yaml' for namespace 'example'." "$out" >/dev/null; then
  echo "Expected payload info message not found in output" >&2
  echo "--- Begin output ---" >&2
  sed -n '1,200p' "$out" >&2 || true
  echo "--- End output ---" >&2
  exit 1
fi