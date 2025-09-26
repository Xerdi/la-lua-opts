#!/usr/bin/env bash
# Public domain.
# Originally written by Erik Nijenhuis, 2025.
set -euo pipefail
cd "$(dirname "$0")"

# Run la-lua-opts with --git-dir pointing to project root, capture output
out=$(mktemp)
if ! la-lua-opts -o build --git-dir="$(realpath "$PWD/../..")" example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi

# Ensure there are no errors in the output
if grep -Ei "(^|[^a-z])error(:|\b)" "$out" >/dev/null; then
  echo "Found errors in output" >&2
  cat "$out" >&2
  exit 1
fi

# Fail if git HEAD could not be read from the project directory
if grep -F "Warning: couldn't read HEAD from git project directory" "$out" >/dev/null; then
  echo "Git HEAD could not be read from the project directory (warning present)" >&2
  cat "$out" >&2
  exit 1
fi

# Ensure we have evidence that a git directory was detected/handled
if ! grep -E "Info: using git directory|gitinfo-lua|git project directory" "$out" >/dev/null; then
  echo "Did not find confirmation that a git directory was found or gitinfo-lua was involved" >&2
  echo "Searched for one of: 'Info: using git directory', 'gitinfo-lua', 'git project directory'" >&2
  echo "Output was:" >&2
  cat "$out" >&2
  exit 1
fi
