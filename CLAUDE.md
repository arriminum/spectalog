# CLAUDE.md

Entry point for Claude Code in the **spectalog** repository.

The full working guide lives in [AGENTS.md](AGENTS.md) — read it first. It covers the project overview, repository layout, coding conventions, the behavior contract, and the safety rules. This file only adds Claude-specific reminders.

## Quick facts

- Spectalog is a single **Bash** log-viewer script (`set -Eeuo pipefail`): `src/spectalog`.
- It shows a vhost's log from `/var/www/<vhost>` (or a configured path) on a Linux server; it is read-only.
- Source of truth for behavior is the script itself, then [docs/usage.md](docs/usage.md), then [README.md](README.md).

## Common commands

```bash
make            # list targets
make check      # shellcheck + version-check (run before finishing any change)
make fmt        # shfmt reformat — OPT-IN, do not run unless asked
make build      # produce dist/spectalog
```

## Reminders for Claude

- **Verify before editing.** Read `src/spectalog` before changing behavior; do not rely on memory of what the script "should" do.
- **Run `make check`** after edits and report the result honestly.
- **Bump the version.** Any change to `src/spectalog` must bump the version (SemVer) in **both** `VERSION` and `SPECTALOG_VERSION`, and add a `CHANGELOG.md` entry. `make check` fails if the two version values disagree. See [RELEASING.md](RELEASING.md) for the full release checklist.
- **Keep docs in sync.** A behavior change must update `docs/usage.md`, `README.md`, and `AGENTS.md` in the same change.
- **Language & style.** Write all `.md` and `Makefile` text in **English**, as an SOP with imperative/infinitive verbs.
- **Markdown formatting.** Do not hard-wrap Markdown paragraphs — keep each paragraph on a single line unless there is an explicit semantic reason to break (list item, code block, table, heading, intentionally separated paragraph). See [AGENTS.md](AGENTS.md).
- **Preserve safety properties.** Never loosen the `<vhost>` validation, and never add write/delete behavior — spectalog is read-only by design.
