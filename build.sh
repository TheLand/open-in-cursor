#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
APP_NAME="Open in Cursor"
APP_PATH="dist/${APP_NAME}.app"
CONTENTS="$APP_PATH/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
BUILD_DIR="dist/.build"
MIN_MACOS="13.0"
SWIFT_SOURCES=(src/LauncherCore.swift src/launcher.swift)
SWIFT_FLAGS=(-O -parse-as-library "${SWIFT_SOURCES[@]}")

compile_launcher() {
	local arch="$1"
	local output="$2"
	swiftc "${SWIFT_FLAGS[@]}" -target "${arch}-apple-macos${MIN_MACOS}" -o "$output"
}

echo "Building ${APP_NAME} v${VERSION}..."

rm -rf "$APP_PATH"
mkdir -p "$MACOS" "$RESOURCES" "$BUILD_DIR"

sed "s/@@VERSION@@/${VERSION}/g" src/Info.plist.template > "$CONTENTS/Info.plist"
plutil -lint "$CONTENTS/Info.plist"

compile_launcher arm64 "$BUILD_DIR/launcher-arm64"
compile_launcher x86_64 "$BUILD_DIR/launcher-x86_64"
lipo -create -output "$MACOS/launcher" "$BUILD_DIR/launcher-arm64" "$BUILD_DIR/launcher-x86_64"
chmod +x "$MACOS/launcher"

if [[ ! -f assets/AppIcon.icns ]] && [[ -f /Applications/Cursor.app/Contents/Resources/Cursor.icns ]]; then
	chmod +x scripts/generate-icon.sh
	./scripts/generate-icon.sh
fi

if [[ -f assets/AppIcon.icns ]]; then
	cp assets/AppIcon.icns "$RESOURCES/AppIcon.icns"
	/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$CONTENTS/Info.plist" 2>/dev/null \
		|| /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$CONTENTS/Info.plist"
fi

echo "Built ${APP_PATH} ($(lipo -info "$MACOS/launcher" | cut -d: -f2-))"
