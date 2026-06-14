#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
APP_NAME="Open in Cursor"
APP_PATH="dist/${APP_NAME}.app"
DMG_PATH="dist/OpenInCursor-${VERSION}.dmg"
STAGING="dist/dmg-staging"

if [[ ! -d "$APP_PATH" ]]; then
	echo "App bundle not found. Run ./build.sh first." >&2
	exit 1
fi

echo "Packaging ${DMG_PATH}..."

rm -rf "$STAGING"
mkdir -p "$STAGING"
ditto "$APP_PATH" "$STAGING/${APP_NAME}.app"
ln -sf /Applications "$STAGING/Applications"

rm -f "$DMG_PATH"
hdiutil create \
	-volname "Open in Cursor ${VERSION}" \
	-srcfolder "$STAGING" \
	-ov \
	-format UDZO \
	"$DMG_PATH" >/dev/null

rm -rf "$STAGING"
cp "$DMG_PATH" "dist/OpenInCursor.dmg"
echo "Created ${DMG_PATH}"
echo "Created dist/OpenInCursor.dmg"
