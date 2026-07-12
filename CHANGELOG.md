# Changelog

All notable changes to **spectalog** are recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (`MAJOR.MINOR.PATCH`):

- **MAJOR** — incompatible change to how spectalog is invoked or behaves.
- **MINOR** — new, backward-compatible functionality.
- **PATCH** — backward-compatible bug fix or small change.

## How to update this file

On every change to `src/spectalog`:

1. Add an entry under `[Unreleased]` in the correct group (`Added`, `Changed`, `Fixed`, `Removed`).
2. Pick the new version per the rules above.
3. Set the same value in **both** the `VERSION` file and `SPECTALOG_VERSION` in `src/spectalog`.
4. Move the `[Unreleased]` notes into a new dated version section.
5. Run `make check` — it fails if `VERSION` and the script disagree.

## [Unreleased]

## [0.2.0] - 2026-07-12

### Changed

- `-f` now follows the log with `tail -F` instead of `tail -f`, so it waits for the file to appear (and reopens it if replaced) instead of aborting when a freshly deployed vhost has not written today's log yet.
- The existence check for the resolved log file now only applies without `-f`; with `-f`, spectalog no longer requires the file to exist before it starts following.
- The "log file not found" error now hints at using `-f` to wait for the file instead.

## [0.1.0] - 2026-07-05

First tracked release. Baseline: `spectalog <vhost> [-f]` resolves the log to show via three sources in order — `./<vhost>-log`, `$HOME/.spectalog/<vhost>-log`, then a default of `/var/www/<vhost>/logs/application-YYYYMMDD.log` for today.

### Added

- `spectalog <vhost> [-f]` — show the last 15 lines, or follow with `-f`.
- Three-tier log resolution: current-directory config file, `$HOME/.spectalog` config file, and a dynamic default computed with today's date.
- `spectalog version` command (also `--version` / `-v`) that prints the version.
- `spectalog -h` / `--help` usage text.
- Embedded `SPECTALOG_VERSION` in the script and a `VERSION` file as the repository source of truth, kept in sync by `make check` (`version-check`).
- This changelog.
