# Development

Guide for contributors to Open in Cursor.

## Prerequisites

- macOS 13+
- Xcode Command Line Tools
- [Cursor](https://cursor.com) (optional, to regenerate the icon from `Cursor.icns`)

## Setup

```bash
git clone https://github.com/TheLand/open-in-cursor.git
cd open-in-cursor
chmod +x build.sh package.sh install.sh scripts/*.sh .githooks/*
```

## Build and test

```bash
./scripts/test.sh            # swift test + bundle/dmg validation
./build.sh                   # dist/Open in Cursor.app
./package.sh                 # dist/OpenInCursor-{version}.dmg + dist/OpenInCursor.dmg
./install.sh                 # copy to /Applications
```

Regenerate the icon (optional):

```bash
./scripts/generate-icon.sh   # assets/AppIcon.icns + assets/icon-preview.png
```

## Git hooks (local build fallback)

Git has no native `pre-add` hook. The `git add` alias rebuilds the `.dmg` before staging:

```bash
./scripts/install-hooks.sh   # one-time setup
git add src/launcher.swift   # rebuilds .dmg if needed, then stages
```

`pre-commit` is a safety net if you use `\git add` (bypass alias).

## Project structure

```
src/                  LauncherCore.swift (logic) + launcher.swift (UI)
Tests/                Swift unit tests (swift test)
scripts/              test.sh, generate-icon.sh, install-hooks.sh
.githooks/            pre-add-build and pre-commit
.github/workflows/    GitHub Actions (CI + release)
build.sh              builds .app
package.sh            builds .dmg
Package.swift         swift test configuration
assets/               AppIcon.icns, icon-preview.png
```

## Publishing a release

Every push of a semver tag (`v*`) triggers [`.github/workflows/release.yml`](../.github/workflows/release.yml), which runs tests, builds the `.dmg`, and publishes a GitHub Release automatically.

```bash
echo "1.0.1" > VERSION
git commit -am "chore: bump version to 1.0.1"
git tag v1.0.1
git push origin main && git push origin v1.0.1
```

Release assets:

- `OpenInCursor.dmg` — stable URL for the latest version (`/releases/latest/download/OpenInCursor.dmg`)
- `OpenInCursor-{version}.dmg` — versioned artifact

### Manual fallback

```bash
./build.sh && ./package.sh
# GitHub → Releases → New release → attach dist/OpenInCursor.dmg
```

| Method | Requirements | Output |
| --- | --- | --- |
| GitHub Actions (tag `v*`) | Push tag to GitHub | Automatic release with `.dmg` |
| Git hooks + manual upload | Developer Mac | `.dmg` in `dist/` uploaded by hand |
| Local install | `./install.sh` | App in `/Applications` (dev only) |

## Contributing

- Open a pull request on GitHub
- Run `./scripts/test.sh` before every push
- For releases: update `VERSION`, create a semver tag `v*`, verify GitHub Actions succeeds
- For the icon: edit `scripts/render-open-badge.swift` or pass another SF Symbol to `generate-icon.sh`, then run `./scripts/generate-icon.sh`

## CI pipelines

- **[`.github/workflows/ci.yml`](../.github/workflows/ci.yml)** — tests on branch pushes and pull requests (`macos-latest`)
- **[`.github/workflows/release.yml`](../.github/workflows/release.yml)** — tests, builds, and publishes a GitHub Release on every tag push matching `v*`
