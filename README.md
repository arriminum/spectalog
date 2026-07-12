# spectalog

**Spectalog** is a small, auditable script to peek at a vhost's log without typing the full `tail -f /var/www/<vhost>/logs/application-YYYYMMDD.log` every time. Run `spectalog <vhost>` from anywhere and it finds the right log for you.

It reads three sources, in order, to decide which log file to show:

1. `./<vhost>-log` — a one-line file in the **current directory**, holding a fixed log path (useful for a project's own deploy directory).
2. `$HOME/.spectalog/<vhost>-log` — the same format, usable from any directory.
3. A **default**, computed on the fly: `/var/www/<vhost>/logs/application-YYYYMMDD.log` with today's date — the common case for an app's own rotating log, with no config file needed.

This tool is maintained for and used by [Arriminum](https://arriminum.com) projects.

## What it does

For each run, spectalog performs these steps in order:

1. Read `<vhost>` from the command line; refuse to run without it.
2. Look for `./<vhost>-log` in the current directory.
3. If not found, look for `$HOME/.spectalog/<vhost>-log`.
4. If neither exists, fall back to `/var/www/<vhost>/logs/application-YYYYMMDD.log` using today's date.
5. Print which log file was resolved, then show it: the last 15 lines, or follow it live with `-f`.

If the resolved log file does not exist, spectalog stops with an error instead of guessing further — unless `-f` was given, in which case it waits for the file to appear (useful right after a deploy, before the app has written today's first line).

## Basic usage

```bash
spectalog hqjury          # last 15 lines of hqjury's log
spectalog hqjury -f       # follow hqjury's log (tail -F), waiting if it does not exist yet
```

### Fixed log path (e.g. an Apache/Nginx vhost log)

Create a one-line file named `<vhost>-log`, either in the directory where you run `spectalog` or in `$HOME/.spectalog/`:

```bash
mkdir -p ~/.spectalog
echo "/var/log/apache2/error_hqjury.log" > ~/.spectalog/hqjury-log
```

Now `spectalog hqjury` shows that file from any directory. Use this for logs whose path never changes; **do not** put a dated application log path here — it will go stale the next day. Dated logs are handled by the built-in default (see below).

### Default: an app's own rotating log

If no config file matches, spectalog computes the path itself using the current date, exactly the way the old per-project `showlog` script did:

```txt
/var/www/<vhost>/logs/application-YYYYMMDD.log
```

No configuration is needed for this case.

See [docs/usage.md](docs/usage.md) for the full reference.

Check the installed version at any time:

```bash
spectalog version     # also: spectalog --version | spectalog -v
```

## Versioning

Spectalog follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The current version lives in the [VERSION](VERSION) file and is embedded in the script (`spectalog version`); `make check` keeps the two in sync. See [CHANGELOG.md](CHANGELOG.md) for the history of changes, and [RELEASING.md](RELEASING.md) for the step-by-step release process.

## Make targets

Use the included [Makefile](Makefile) to build, check, and install the script.

- `make help` — list all available targets (default).
- `make build` — copy `src/spectalog` into `dist/` and mark it executable.
- `make check` — lint with `shellcheck` and verify `VERSION` matches the script.
- `make fmt` — reformat `src/spectalog` in place with `shfmt` (opt-in).
- `make install` — install the script to `/usr/local/bin/spectalog` (needs `sudo`).
- `make uninstall` — remove the installed script.
- `make clean` — remove the `dist/` build artifacts.

## Configuration & installation

Spectalog is installed as a global command on the server:

```bash
sudo make install          # installs to /usr/local/bin/spectalog
```

Or install manually:

```bash
sudo cp src/spectalog /usr/local/bin/spectalog
sudo chmod +x /usr/local/bin/spectalog
```

Once installed it can be run from any directory. To uninstall:

```bash
sudo make uninstall        # or: sudo rm -f /usr/local/bin/spectalog
```

## Safety

- Refuses to run without a `<vhost>` argument.
- Rejects a `<vhost>` containing `/`.
- Stops with an error if the resolved log file does not exist, instead of silently trying something else — except with `-f`, which waits for the file to appear rather than writing one itself.
- Never writes, rotates, or deletes any file — it only reads and prints logs.

## Repository

```txt
git@github.com:arriminum/spectalog.git
```

## License

Proprietary — © Arriminum. Internal use only.
