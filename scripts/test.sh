#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="Open in Cursor"
APP_PATH="dist/${APP_NAME}.app"
VERSION="$(tr -d '[:space:]' < VERSION)"
DMG_PATH="dist/OpenInCursor-${VERSION}.dmg"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; exit 1; }

echo "==> Swift unit tests"
swift test

echo "==> Build app bundle"
chmod +x build.sh package.sh
./build.sh
./package.sh

echo "==> Validate app bundle"
[[ -x "${APP_PATH}/Contents/MacOS/launcher" ]] || fail "launcher executable missing"
plutil -lint "${APP_PATH}/Contents/Info.plist" >/dev/null || fail "invalid Info.plist"

bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "${APP_PATH}/Contents/Info.plist")"
[[ "$bundle_id" == "com.openincursor.app" ]] || fail "unexpected CFBundleIdentifier: ${bundle_id}"

bundle_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${APP_PATH}/Contents/Info.plist")"
[[ "$bundle_version" == "$VERSION" ]] || fail "version mismatch: ${bundle_version} != ${VERSION}"

usage_desc="$(/usr/libexec/PlistBuddy -c 'Print :NSAppleEventsUsageDescription' "${APP_PATH}/Contents/Info.plist" 2>/dev/null || true)"
[[ -n "$usage_desc" ]] || fail "NSAppleEventsUsageDescription missing from Info.plist"

archs="$(lipo -info "${APP_PATH}/Contents/MacOS/launcher" | sed 's/.*: //')"
[[ "$archs" == *"arm64"* ]] || fail "launcher missing arm64 architecture"
[[ "$archs" == *"x86_64"* ]] || fail "launcher missing x86_64 architecture"

echo "==> Validate DMG"
[[ -f "$DMG_PATH" ]] || fail "DMG not found at ${DMG_PATH}"
[[ -f "dist/OpenInCursor.dmg" ]] || fail "Latest DMG alias not found at dist/OpenInCursor.dmg"

pass "swift tests"
pass "app bundle structure"
pass "universal binary (${archs})"
pass "dmg packaging (${DMG_PATH})"

echo "All tests passed."
