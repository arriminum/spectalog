# spectalog — usage

Spectalog shows the log of a vhost deployed under `/var/www`, without
requiring you to type the full `tail` command or to `cd` into the project's
`src` directory.

## Command line

```bash
spectalog <vhost> [-f]
```

- `<vhost>` — required. The name of the vhost directory in `/var/www` (for
  example, `hqjury` for `/var/www/hqjury`).
- `-f` — optional, second argument. Follows the log with `tail -f` instead of
  printing the last 15 lines.

Other commands:

```bash
spectalog version      # also: spectalog --version | spectalog -v
# → spectalog 0.1.0

spectalog -h            # also: spectalog --help
```

## Log resolution order

Spectalog tries three sources, in this order, and uses the first match:

1. **`./<vhost>-log`** — a file named `<vhost>-log` in the **current working
   directory**. Its content is a single line: the absolute path to the log
   file. Use this when you want a project-local override without touching
   `$HOME`.
2. **`$HOME/.spectalog/<vhost>-log`** — same one-line format, stored under
   the user's home directory so it applies regardless of the current
   directory.
3. **Default (no config file needed)** — computed as:

   ```txt
   /var/www/<vhost>/logs/application-YYYYMMDD.log
   ```

   using today's date. This matches the layout of an application's own
   rotating daily log, the same convention used by the original per-project
   `showlog` script.

Spectalog prints which log file it resolved to before showing its content, so
you always know which of the three sources was used:

```txt
[hqjury] /var/log/apache2/error_hqjury.log
```

### When to use a config file vs. the default

- Use a **config file** (`./<vhost>-log` or `$HOME/.spectalog/<vhost>-log`)
  for logs with a **fixed path** that never changes day to day — typically
  the web server's own log (Apache/Nginx `error_*.log` or `access_*.log`).
- Rely on the **default** for an app's **own rotating log**, since its path
  changes every day. Do not hardcode a dated path (e.g.
  `application-20260705.log`) in a config file — it goes stale the next day.

### Config file format

One line, no trailing content besides the path itself:

```txt
/var/log/apache2/error_hqjury.log
```

Trailing `\r` or `\n` characters are stripped; leading/trailing whitespace is
not.

## Examples

Show the last 15 lines of `hqjury`'s log (resolved via the default rule,
assuming no config file exists):

```bash
spectalog hqjury
```

Follow `hqjury`'s log live:

```bash
spectalog hqjury -f
```

Point `hqjury` at the Apache error log instead of its own application log,
from any directory:

```bash
mkdir -p ~/.spectalog
echo "/var/log/apache2/error_hqjury.log" > ~/.spectalog/hqjury-log
spectalog hqjury
```

Override that just for one deploy directory, without touching `$HOME`:

```bash
cd /home/user/deploys/hqjury
echo "/var/www/hqjury/logs/application-20260601.log" > hqjury-log
spectalog hqjury   # uses the file above, ignoring $HOME/.spectalog and the default
```

## When spectalog aborts

Spectalog stops with an error, and prints nothing else, in these cases:

- `<vhost>` argument missing.
- `<vhost>` contains a `/` (rejected to avoid escaping `/var/www`).
- The resolved log file does not exist.

## Known limitations

- Spectalog does not create, rotate, or manage log files — it only locates
  and reads them.
- The current-directory config file (`./<vhost>-log`) is matched against
  `$(pwd)`, so its precedence depends on where you invoke `spectalog` from.

## Make targets

The repository includes a `Makefile` for building, checking, and installing
the script. Run `make help` to list them.

- `make help` — list all available targets (default goal).
- `make build` — copy `src/spectalog` into `dist/spectalog` and mark it
  executable. Use this to produce a distributable copy without installing.
- `make check` — lint `src/spectalog` with `shellcheck` and verify the
  `VERSION` file matches `SPECTALOG_VERSION` in the script (non-destructive).
- `make fmt` — reformat `src/spectalog` in place with `shfmt -i 4 -ci`.
  Opt-in; not run by `make check`, so it never touches your formatting unless
  you ask.
- `make install` — build, then install to `/usr/local/bin/spectalog` with
  mode `0755`. Needs `sudo` for the default prefix. Override the location
  with `PREFIX=...`.
- `make uninstall` — remove the installed script from the target path.
- `make clean` — remove the `dist/` build artifacts.

### Overriding the install location

```bash
sudo make install PREFIX=/usr/local     # default → /usr/local/bin/spectalog
make install PREFIX="$HOME/.local"      # user-local → ~/.local/bin/spectalog
```
