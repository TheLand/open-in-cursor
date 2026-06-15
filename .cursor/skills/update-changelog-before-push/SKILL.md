---
name: update-changelog-before-push
description: >-
  Updates CHANGELOG.md in Keep a Changelog format before git push, release, or
  tag. Use when pushing to remote, publishing a release, creating a semver tag,
  or when the user asks to ship changes for open-in-cursor.
---

# Update CHANGELOG Before Push

**Mandatory gate:** do not run `git push` until `CHANGELOG.md` reflects every user-facing change that will be pushed.

## When this applies

- `git push` (any branch)
- Release or tag workflow (`v*`)
- User asks to publish, ship, or release

Skip only for pushes that change **only** `CHANGELOG.md` itself (no other pending user-facing changes).

## Workflow

Copy and track:

```
Changelog gate:
- [ ] Step 1: Inspect pending changes
- [ ] Step 2: Decide if CHANGELOG needs an update
- [ ] Step 3: Update CHANGELOG.md
- [ ] Step 4: Commit changelog (separate commit if other work already committed)
- [ ] Step 5: Push only after changelog is current
```

### Step 1: Inspect pending changes

Run in parallel:

```bash
git status
git diff
git log --oneline "$(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~20)..HEAD"
cat VERSION
```

Read [CHANGELOG.md](../../../CHANGELOG.md) (repo root).

### Step 2: Decide if CHANGELOG needs an update

Update the changelog when any pushed change is **user-facing**:

- App behavior, errors, permissions, packaging
- README or docs that affect installation or usage
- Version bump (`VERSION`)

Do **not** add entries for internal-only work (CI tweaks, refactors, dev tooling) unless they affect users or releases.

**Distribution note:** releases are unsigned/unnotarized. User-facing docs and in-app copy must keep the Gatekeeper / first-launch flow accurate. See [docs/development.md](../../../docs/development.md#distribution-limitations).

### Step 3: Update CHANGELOG.md

Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — match the existing file style.

**Unreleased section:** if changes are on `main` but not yet tagged, add or extend:

```markdown
## [Unreleased]

### Added
- ...

### Changed
- ...

### Fixed
- ...
```

**Release section:** when tagging, convert `[Unreleased]` to a versioned section:

```markdown
## [1.0.2] - YYYY-MM-DD

### Fixed
- ...
```

Rules:

- Use today's date for new release sections (`YYYY-MM-DD`).
- Prefer `Added`, `Changed`, `Fixed`, `Removed`, `Security` — omit empty sections.
- Write for end users, not commit hashes.
- Add compare link at the bottom:

```markdown
[Unreleased]: https://github.com/TheLand/open-in-cursor/compare/v1.0.1...HEAD
[1.0.2]: https://github.com/TheLand/open-in-cursor/compare/v1.0.1...v1.0.2
```

When releasing, also update `VERSION` and follow [docs/development.md](../../../docs/development.md#publishing-a-release).

### Step 4: Commit

If changelog was updated:

```bash
git add CHANGELOG.md
git commit -m "$(cat <<'EOF'
Update CHANGELOG for pending changes.

EOF
)"
```

For a release, changelog + version bump can share one commit or stay separate — match recent repo history.

### Step 5: Push

Only after Steps 1–4 pass:

```bash
git push origin <branch>
# if releasing:
git push origin v<version>
```

## Release notes helper

For GitHub Releases, reuse the latest `CHANGELOG.md` section as the release body. Include:

```markdown
**Full Changelog**: https://github.com/TheLand/open-in-cursor/blob/main/CHANGELOG.md
```

## Example

Pending change: bundled Cursor CLI fallback when shell command is missing.

```markdown
## [1.0.1] - 2026-06-15

### Fixed

- **Cursor CLI no longer required in PATH.** Uses the CLI bundled inside `Cursor.app`.
- Clearer error when Cursor is not installed at all.

### Changed

- README: Cursor in Applications is enough; shell command is optional.
```
