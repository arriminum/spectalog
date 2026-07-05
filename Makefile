# =============================================================================
# spectalog — Makefile
#
# Build, check, and install the spectalog log-viewer script.
# The project is a single Bash script: src/spectalog.
#
#   make            List available targets (default).
#   make build      Copy the script into dist/ and mark it executable.
#   make check      Lint with shellcheck.
#   make fmt        Reformat the source script in place with shfmt (opt-in).
#   make install    Install to $(BINDIR)/spectalog (needs sudo for /usr/local).
#   make uninstall  Remove the installed script.
#   make clean      Remove build artifacts.
# =============================================================================

SHELL := /bin/sh

# --- Identity ----------------------------------------------------------------
NAME     := spectalog
SRC      := src/$(NAME)
DISTDIR  := dist
DIST     := $(DISTDIR)/$(NAME)
VERSFILE := VERSION

# --- Install paths (override on the command line, e.g. PREFIX=$HOME/.local) ---
PREFIX  := /usr/local
BINDIR  := $(PREFIX)/bin
TARGET  := $(BINDIR)/$(NAME)

# --- Tools -------------------------------------------------------------------
SHELLCHECK := shellcheck
SHFMT      := shfmt
SHFMT_ARGS := -i 4 -ci
INSTALL    := install

.DEFAULT_GOAL := help
.PHONY: help build check lint version-check fmt install uninstall clean

# List targets. Each documented target carries a "## text" comment.
help: ## List available targets
	@printf 'spectalog — make targets\n\n'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[1m%-12s\033[0m %s\n", $$1, $$2}'
	@printf '\nInstall prefix: %s (override with PREFIX=...)\n' '$(PREFIX)'

# Copy the source script into dist/ and mark it executable.
build: ## Copy the script into dist/ and mark it executable
	@mkdir -p $(DISTDIR)
	cp $(SRC) $(DIST)
	chmod +x $(DIST)
	@printf 'built: %s\n' '$(DIST)'

# Run static checks: shellcheck + VERSION/script consistency.
# Formatting is opt-in via `make fmt`.
check: lint version-check ## Lint with shellcheck and verify the version is in sync

lint:
	$(SHELLCHECK) $(SRC)

# Fail if the VERSION file and SPECTALOG_VERSION in the script disagree.
version-check: ## Verify VERSION matches SPECTALOG_VERSION in the script
	@file_ver=$$(tr -d '[:space:]' <$(VERSFILE)); \
	script_ver=$$(sed -n 's/^SPECTALOG_VERSION="\([^"]*\)".*/\1/p' $(SRC) | head -n 1); \
	if [ "$$file_ver" != "$$script_ver" ]; then \
		printf 'Error: VERSION (%s) != script SPECTALOG_VERSION (%s)\n' "$$file_ver" "$$script_ver" >&2; \
		printf 'Update both to the same value, then re-run.\n' >&2; \
		exit 1; \
	fi; \
	printf '[version] VERSION and script match: %s\n' "$$file_ver"

# Reformat the source script in place. Opt-in — not part of `make check`.
fmt: ## Reformat the source script in place with shfmt (opt-in)
	$(SHFMT) $(SHFMT_ARGS) -w $(SRC)

# Build, then install the script (mode 0755). Needs sudo for /usr/local.
install: build ## Install to $(BINDIR)/spectalog (needs sudo for /usr/local)
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) -m 0755 $(DIST) $(TARGET)
	@printf 'installed: %s\n' '$(TARGET)'

# Remove the installed script.
uninstall: ## Remove the installed script
	rm -f $(TARGET)
	@printf 'removed: %s\n' '$(TARGET)'

# Remove build artifacts.
clean: ## Remove build artifacts
	rm -rf $(DISTDIR)
	@printf 'cleaned: %s\n' '$(DISTDIR)'
