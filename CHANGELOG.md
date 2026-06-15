# Changelog

All notable changes to **Open in Cursor** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-06-15

### Fixed

- **Cursor CLI no longer required in PATH.** If the `cursor` shell command is not installed, the app now uses the CLI bundled inside `Cursor.app` (in `/Applications` or `~/Applications`).
- Clearer error when Cursor is not installed at all.

### Changed

- README updated: Cursor in Applications is enough; the shell command is optional and only needed for terminal use.

## [1.0.0] - 2026-06-15

### Added

- macOS utility to open the current Finder folder in Cursor in a new window (`cursor -n <path>`).
- Spotlight launch: install to Applications and run via `Cmd+Space` → "Open in Cursor".
- Finder automation with in-app permission guide (**Request Permission**, **Open Settings**).
- Universal binary (Apple Silicon and Intel).
- GitHub Actions CI on push/PR and automatic release on semver tags.
- `.dmg` distribution via GitHub Releases.

[1.0.1]: https://github.com/TheLand/open-in-cursor/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/TheLand/open-in-cursor/releases/tag/v1.0.0
