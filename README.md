# La Lua Opts

La Lua Opts is an experimental extension of command‑line options for LuaLaTeX. It offers:

- A practical proxy/wrapper for the `lualatex` executable to simplify common flags.
- Extended options to inject `\DocumentMetadata{...}` via an init script.
- Extra options for Xerdi’s Documentation Project (XDP) related packages, such as `gitinfo-lua` and `lua-placeholders`.

This README is structured around these three features so you can pick only what you need.

## Components at a glance

- CLI wrapper: `bin/la-lua-opts` (builds a `lualatex` command with extended flags and sane defaults).
- Init script: `scripts/lua/la-lua-opts-init.lua` (loaded with `--lua=...`; sets engine safety defaults and prepends
  `\DocumentMetadata{...}` when applicable).
- Lua module: `scripts/lua/la-lua-opts.lua` (provides XDP‑related options; runs inside LaTeX via the package).
- LaTeX package: `tex/lualatex/la-lua-opts.sty` (loads the Lua module when your document does
  `\usepackage{la-lua-opts}`).

---

## Proxy options for lualatex (wrapper)

Use the wrapper when you want a convenient CLI that forwards and normalizes options to `lualatex` and ensures the init
script is active.

Key options handled by the wrapper:

- `-o, --output=PATH` or `--output-directory=DIR` set output directory (default: `.`); ensures an absolute path and
  creates the directory.
- `-j, --jobname=NAME` forwards `--jobname` to `lualatex`.
- `--interaction=MODE` forwards interaction mode.
- `--draftmode` forwards LaTeX draftmode.
- Pass‑through options for the other goals (so you can combine goals in one run):
    - Metadata: `-t, --tagging`, `-l, --lang=CODE`, `--pdfversion=VER`, `--pdfstandard=STD` (repeatable),
      `-u, --uncompress` (or `--no-uncompress`).
    - XDP: `-r, --recipe=PATH`, `-p, --payload=PATH`, `-g, --gitdir=PATH`, `--final`.

Invocation shape used by the wrapper:

- `lualatex --lua=$(kpsewhich la-lua-opts-init.lua) …`

Examples:

- Draft compile: `la-lua-opts --draftmode main.tex`
- Final with jobname and output dir: `la-lua-opts --output-directory=build -j mypaper --final main.tex`

---

## Injecting \DocumentMetadata via init script

Use this when you want `\DocumentMetadata{...}` automatically prepended without editing your `.tex`.

How it works (in `scripts/lua/la-lua-opts-init.lua`):

- Runs as an init script via `--lua=...` and configures the engine (halt on error, restricted shell, kpse init).
- Hooks `process_input_buffer`:
    - If the very first line begins with `\DocumentMetadata`, it leaves the input as is.
    - If the buffer begins with `\documentclass`, it prepends exactly one `\DocumentMetadata{...}` built from supplied
      options only. When no metadata options are supplied, it inserts an empty `\DocumentMetadata{}`.
    - Otherwise, it leaves the input unchanged and logs that no metadata was inserted.

Metadata options (only included when supplied):

- `-l, --lang=CODE`
- `--pdfversion=VER`
- `--pdfstandard=STD` (repeatable)
- `-u, --uncompress` or `--no-uncompress`
- `-t, --tagging` (adds `tagging=on` and logs a message)

Example adding tagging and language without editing your file:

- `la-lua-opts -t -l en main.tex`

---

## XDP‑related options (lua‑placeholders, gitinfo‑lua)

Use this when working with Xerdi’s Documentation Project packages and dynamic data.

How it works (via `scripts/lua/la-lua-opts.lua` + `\usepackage{la-lua-opts}`):

- When your LaTeX document loads `\usepackage{la-lua-opts}`, the Lua module runs inside the LaTeX context and parses
  LuaTeX command‑line args.
- Features:
    - Recipes: `--recipe=FILE` or `--recipe=NS:FILE` -> `lua-placeholders.recipe(…)`.
    - Payloads: `--payload=FILE` or `--payload=NS:FILE` -> `lua-placeholders.payload(…)`.
    - Final mode: `--final` -> `lua-placeholders.set_strict()`.
    - Git directory: `--gitdir=DIR` -> `gitinfo-lua:dir(DIR)`.

Namespacing recipes/payloads:

- Prefix with `NS:` to load into a namespace, e.g. `-r defaults.yaml -r conf:extra.yaml -p data.json -p conf:more.json`.

Minimal example:

- In your document: `\usepackage{la-lua-opts}`
- On the CLI: `la-lua-opts -r defaults.yaml -p data.json --final main.tex`

---

## Installation

Use make to install all files:

    sudo make install

Afterward, `la-lua-opts` will be in your PATH.

Uninstall:

    sudo make uninstall

---

## latexmk integration

You can integrate with latexmk either through the wrapper or directly.

- With the wrapper (simplest):
    - `latexmk -f --lualatex='la-lua-opts %O %S' --outdir=build main.tex`

- Without the wrapper (manual control; used in tests):
    - Command‑line example:

          latexmk -f --lualatex \
            --lualatex="lualatex \
            --lua=$(kpsewhich la-lua-opts.lua) \
            --final" \
            --output-directory=build main.tex \
            %O %S

    - .latexmkrc snippet:

          chomp(my $init_file = `kpsewhich la-lua-opts-init.lua`);
          $pdf_mode = 4;
          $lualatex = "lualatex --lua=$init_file %O %S";
          $lualatex = "$lualatex --final --pdfversion=2.0";
          $out_dir = 'build';

Remember: for XDP-related features, your document must load the package:

    \usepackage{la-lua-opts}

---

## Examples

- Add metadata only: `la-lua-opts -t -l en --pdfversion=2.0 main.tex`
- XDP data with namespaces:
  `la-lua-opts -r defaults.yaml -r conf:extra.yaml -p data.json -p ns:more.json --final main.tex`
- Combine all features in one run: same command as above; the wrapper forwards options to init and module.

---

## Testing

- Run all tests:

  make test

Tests assume a fully installed TeX Live distribution.

## Development notes

- The init script reads options from LuaTeX argv; by default, the other options are also available from the module
  context.
- The module looks for: `--recipe=…`, `--payload=…`, `--final`, `--gitdir=…`.

## License

Copyright 2025 Xerdi. See source headers.
