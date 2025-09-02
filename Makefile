SHELL := /bin/bash

.ONESHELL:
.PHONY: test

PREFIX       ?= /usr/local
TEXMFLOCAL   := $(shell kpsewhich --var-value TEXMFLOCAL)
BINLINK      := $(PREFIX)/bin/la-lua-opts

MANIFEST_DIR := $(TEXMFLOCAL)
MAN_FILES    := $(MANIFEST_DIR)/.la-lua-opts.files
MAN_LINKS    := $(MANIFEST_DIR)/.la-lua-opts.links

export PROJECT_ROOT:=$(shell pwd)
export PATH:=$(PROJECT_ROOT)/bin:$(PATH)
export TEXMFCNF:=$(PROJECT_ROOT):
export TEXMFHOME:=$(PROJECT_ROOT)

package dist:
	tar --transform 's,^\.,la-lua-opts,' \
		-czvf la-lua-opts.tar.gz \
		./bin ./scripts ./tex

install: dist
	tar -xvzf la-lua-opts.tar.gz \
		--strip-components=1 \
		-C $(TEXMFLOCAL)
	mktexlsr
	ln -sf $(TEXMFLOCAL)/bin/la-lua-opts /usr/local/bin/la-lua-opts
	tlmgr path add

	@mkdir -p "$(MANIFEST_DIR)"
	@tar -tzf la-lua-opts.tar.gz \
	| sed -e 's|^la-lua-opts/||' -e '/\/$$/d' \
	| awk -v root="$(TEXMFLOCAL)" '{print root "/" $$0}' > "$(MAN_FILES)"
	@printf "%s\n" "$(BINLINK)" > "$(MAN_LINKS)"

uninstall:
	@if [ -f "$(MAN_FILES)" ]; then \
	  while IFS= read -r f; do \
	    [ -n "$$f" ] && rm -f "$$f"; \
	  done < "$(MAN_FILES)"; \
	else \
	  echo "Warning: $(MAN_FILES) missing"; \
	fi

	@if [ -f "$(MAN_FILES)" ]; then \
	  awk -F/ 'BEGIN{OFS="/"}{NF--; print}' "$(MAN_FILES)" \
	  | sort -u | sort -r \
	  | while IFS= read -r d; do \
	      [ -d "$$d" ] && rmdir "$$d" 2>/dev/null || true; \
	    done; \
	fi

	@if [ -f "$(MAN_LINKS)" ]; then \
	  while IFS= read -r l; do \
	    [ -n "$$l" ] && rm -f "$$l"; \
	  done < "$(MAN_LINKS)"; \
	else \
	  echo "Warning: $(MAN_LINKS) missing"; \
	fi

	mktexlsr

	@rm -f "$(MAN_FILES)" "$(MAN_LINKS)"

clean:
	@shopt -s nullglob; \
	for builddir in tests/*/build; do \
	  [ -d "$$builddir" ] || continue; \
	  pushd "$$builddir" >/dev/null; \
	  aux_found=0; \
	  for aux in *.aux; do \
	    aux_found=1; \
	    echo "Cleaning $$builddir with latexmk -C $$aux"; \
	    latexmk -C "$$aux" >/dev/null 2>&1 || true; \
	  done; \
	  if [ "$$aux_found" -eq 0 ]; then \
	    echo "No .aux found in $$builddir, skipping"; \
	  fi; \
	  popd >/dev/null; \
	done

test: clean
	bash ./tests/run-tests.sh
