# AGENTS.md — spectalog

Operating guide for AI agents and maintainers working on **spectalog**. Read this before changing anything.

## What this project is

Spectalog is a single **Bash** script (`#!/usr/bin/env bash`, `set -Eeuo pipefail`) that shows a vhost's log without requiring the operator to type the full `tail` command or `cd` into the project. It has no build step
beyond copying the script, no runtime dependencies of its own, and reads its per-vhost configuration (if any) from one-line `<vhost>-log` files.

Authoritative behavior lives in three places, in this order of trust:

1. `src/spectalog` — the actual script (source of truth for behavior).
2. [docs/usage.md](docs/usage.md) — the operator-facing reference.
3. [README.md](README.md) — the overview.

If code and docs disagree, the code wins — then fix the docs.

## Repository layout

```txt
.
├── src/spectalog            # the script (Bash) — the source of truth
├── dist/spectalog           # build output (git-ignored / disposable)
├── VERSION                  # version number (repo source of truth)
├── CHANGELOG.md             # notable changes per version
├── docs/usage.md            # operator reference
├── Makefile                 # build / check / install / uninstall
├── README.md                # overview
├── AGENTS.md                # this file
├── CLAUDE.md                # Claude Code entry point (points here)
└── spectalog.code-workspace # VS Code workspace + recommended extensions
```

## How to work here

- **Build:** `make build` → copies `src/spectalog` to `dist/spectalog`, `+x`.
- **Check:** `make check` → `shellcheck` + `version-check` (VERSION vs script); must pass clean.
- **Format:** `make fmt` → `shfmt -i 4 -ci -w` in place. **Opt-in** — the maintainer keeps a hand-tuned style, so do **not** run `make fmt` or reformat the script unless explicitly asked.
- **Install:** `sudo make install` → `/usr/local/bin/spectalog` (mode 0755).
- **Uninstall:** `sudo make uninstall`. **Clean:** `make clean`.

Always run `make check` before considering a change done.

## Coding conventions

Match the existing style in `src/spectalog`:

- **Bash, strict mode.** Shebang `#!/usr/bin/env bash`; keep `set -Eeuo pipefail` at the top. Bashisms (`[[ ]]`, `local`, `trap ... ERR`) are expected — this is not a POSIX-sh script.
- **Indent with 4 spaces** (never tabs).
- **`snake_case`** for functions and variables (e.g. `error_exit`, `log_file`, `vhost`).
- **Fail fast.** Validate the `<vhost>` argument before touching the filesystem. On error, print `Error: <reason>` to stderr and `exit 1`.
- **Quote every expansion** (`"$var"`). Test files with `[[ -f ]]` before reading them.
- **Log the resolved path with a `[$vhost]` prefix** (e.g. `echo "[$vhost] $log_file"`) before showing its content, so the operator always knows which of the three log sources was used.

## Behavior contract (do not break)

These are the guarantees documented for operators. Changing any of them is a behavior change that must be reflected in `docs/usage.md` and `README.md`:

1. Require a `<vhost>` argument; refuse to run without one.
2. Reject a `<vhost>` containing `/`.
3. Resolve the log path by priority:
   1. `./<vhost>-log` (current working directory).
   2. `$HOME/.spectalog/<vhost>-log`.
   3. Default: `/var/www/<vhost>/logs/application-YYYYMMDD.log`, computed with **today's** date at run time — never cached or hardcoded.
4. Config files (`<vhost>-log`) hold a single, fixed log path — intended for logs that do not rotate by date (e.g. the web server's own log). Never collapse this with the dynamic default; a dated path written into a config file goes stale the next day.
5. Abort with an error if the resolved log file does not exist — never fall back silently past the three sources above. Exception: with `-f`, do not require the file to exist beforehand; let `tail -F` wait for it.
6. Show the last 15 lines by default; `-f` as the second argument follows the log instead (`tail -F`, so it waits for the file to appear and reopens it if replaced).
7. Never write, rotate, or delete any file. Spectalog only reads and prints.

## Safety rules for agents

- **Never** loosen the `<vhost>` validation (no `/`) — it is the only guard against escaping `/var/www` or `$HOME/.spectalog` via the argument.
- **Never** add write/delete behavior to this script; it is read-only by design.
- Treat `dist/` as disposable output; do not hand-edit it.

## Versioning

Spectalog follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) (`MAJOR.MINOR.PATCH`, each part a non-negative integer):

- **MAJOR** — incompatible change to how spectalog is invoked or behaves (e.g. changing the log resolution order or the config file format).
- **MINOR** — new, backward-compatible functionality.
- **PATCH** — backward-compatible bug fix or small change.

The version lives in **two** places that must always match:

- the `VERSION` file (repository source of truth), and
- `SPECTALOG_VERSION` in `src/spectalog` (embedded so the installed binary can report it via `spectalog version`).

`make check` runs `version-check` and fails if the two disagree. There is no build-time injection — update both by hand.

**On every change to `src/spectalog`:**

1. Bump the version per the rules above.
2. Set the same value in `VERSION` **and** `SPECTALOG_VERSION`.
3. Add a `CHANGELOG.md` entry (move it out of `[Unreleased]` into a dated version section with today's date).
4. Run `make check` — it must pass (shellcheck + version-check).

### GitHub releases and Git tags

Keep the repository's Git tags in sync with version numbers:

1. After updating `VERSION`, `SPECTALOG_VERSION`, and `CHANGELOG.md`, commit:

   ```bash
   git add src/spectalog VERSION CHANGELOG.md [other updated files]
   git commit -m "Bump to 0.1.1: description of change"
   ```

2. Create an **annotated Git tag** with the version (always prefix with `v`):

   ```bash
   git tag -a v0.1.1 -m "Version 0.1.1"
   ```

3. Push the tag to the remote:

   ```bash
   git push origin v0.1.1
   ```

4. Create a **GitHub Release** from the tag (web UI or `gh release create`):
   - Paste the relevant section from `CHANGELOG.md` as the release description.
   - Optionally attach `dist/spectalog` as a build artifact.

**Tagging rule:** Always use `v` + version (e.g. `v0.1.0`, `v1.0.0`). This is the Git and GitHub convention for releases.

## Markdown formatting

Do not hard-wrap Markdown paragraphs. Keep each paragraph on a single line unless there is an explicit semantic reason to add a line break, such as a list item, code block, table, heading, or intentionally separated paragraph.

## Documentation duties

Any behavior change **must** update, in the same change:

- `VERSION` + `SPECTALOG_VERSION` (bump) and `CHANGELOG.md` (new entry).
- `docs/usage.md` (resolution order, arg handling, abort conditions, output).
- `README.md` (overview, examples, safety list) if the summary shifts.
- This file, if a convention or contract changes.

Keep all `.md` and `Makefile` text in **English**, written as an SOP with imperative/infinitive verbs ("Read…", "Resolve…", "Print…").
