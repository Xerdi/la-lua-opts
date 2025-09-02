#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

out=$(mktemp)
trap 'rm -f "$out"' EXIT

mkdir -p build

if ! latexmk --lualatex --lualatex="lualatex --lua=$(kpsewhich la-lua-opts-init.lua) %O %S --final --pdfversion=2.0" --output-directory=build example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi

if ! latexmk -r latexmkrc.example --jobname=example2 example > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi

if ! latexmk -f --lualatex --lualatex='la-lua-opts %O %S --final' --jobname=example3 --output-directory=build example.tex > "$out" 2>&1; then
  echo "Command failed" >&2
  exit 1
fi
