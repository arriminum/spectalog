# Releasing spectalog

Guide for publishing a new version of spectalog to GitHub.

## Before you start

Ensure you have:

- `git` configured with your GitHub credentials (or SSH key).
- `gh` CLI installed and authenticated (`gh auth login`).
- All code changes committed and pushed.

## Release checklist

Follow these steps in order to release a new version:

### 1. Decide the version bump

Consult [AGENTS.md → Versioning](AGENTS.md#versioning) and pick the new version
per Semantic Versioning:

- **MAJOR** — incompatible change (e.g. changes the log resolution order or
  the config file format).
- **MINOR** — new, backward-compatible functionality.
- **PATCH** — backward-compatible bug fix or small change.

Example: if the current version is `0.1.0` and you fixed a bug, bump to `0.1.1`.

### 2. Update version and changelog

Edit two files:

**`VERSION`** — replace the content with the new version (e.g., `0.1.1`):

```txt
0.1.1
```

**`src/spectalog`** — find the `SPECTALOG_VERSION` line and update it:

```bash
SPECTALOG_VERSION="0.1.1"
```

**`CHANGELOG.md`** — move the `[Unreleased]` section into a new dated version:

```markdown
## [Unreleased]

## [0.1.1] - 2026-07-10

### Fixed

- Fixed log resolution when the vhost name contains uppercase letters.
```

### 3. Verify the changes

Run the version check to ensure both files are in sync:

```bash
make check
```

It should output:

```txt
shellcheck src/spectalog
[version] VERSION and script match: 0.1.1
```

If it fails, update both files to match exactly and try again.

### 4. Commit the release

Stage all updated files and commit with a clear message:

```bash
git add VERSION src/spectalog CHANGELOG.md [other changed files]
git commit -m "Bump to 0.1.1: fixed uppercase vhost resolution

- Fixed handling of vhost names with uppercase letters
- Updated CHANGELOG and version files"
```

Commit message format:
- First line: `Bump to X.Y.Z: short description`
- Blank line
- Bullet points (optional) with details

### 5. Create a Git tag

Create an annotated tag pointing to the commit (always prefix with `v`):

```bash
git tag -a v0.1.1 -m "Version 0.1.1"
```

List your tags to verify:

```bash
git tag -l | tail -5
```

### 6. Push to remote

Push the commit and the tag:

```bash
git push origin main                # or the branch you're on
git push origin v0.1.1              # push the tag
```

Verify on GitHub that the tag appears:
https://github.com/arriminum/spectalog/releases/tags/v0.1.1

### 7. Create the GitHub Release

Use `gh` to create a release from the tag:

```bash
gh release create v0.1.1 \
  --title "Version 0.1.1" \
  --notes "Copy the release notes from CHANGELOG.md here"
```

Or use the web UI:

1. Go to https://github.com/arriminum/spectalog/releases
2. Click **"Create a new release"**
3. Select tag **`v0.1.1`**
4. Title: **`Version 0.1.1`**
5. Description: paste the relevant section from `CHANGELOG.md`
6. Click **"Publish release"**

### 8. Verify

Check the release page:
https://github.com/arriminum/spectalog/releases/tag/v0.1.1

Confirm:
- Tag is correct (`v0.1.1`).
- Notes match the CHANGELOG.
- The commit hash is visible.

## Rollback

If you pushed a tag by mistake or need to undo:

```bash
# Delete local tag
git tag -d v0.1.1

# Delete remote tag
git push --delete origin v0.1.1

# Delete the GitHub release (web UI only)
```

Then start over from step 2.

## Quick reference

One-liner checklist:

```bash
# 1. Edit VERSION, SPECTALOG_VERSION, CHANGELOG.md
# 2. make check
# 3. git add ...; git commit -m "Bump to X.Y.Z: ..."
# 4. git tag -a vX.Y.Z -m "Version X.Y.Z"
# 5. git push origin main && git push origin vX.Y.Z
# 6. gh release create vX.Y.Z --title "Version X.Y.Z" --notes "..."
# 7. Verify on GitHub
```

## Questions?

See [AGENTS.md → Versioning](AGENTS.md#versioning) for the version rules, or
[CHANGELOG.md](CHANGELOG.md) for how to write release notes.
