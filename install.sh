#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

APP_NAME="Open in Cursor"
TARGET="/Applications/${APP_NAME}.app"

./build.sh

if [[ -d "$TARGET" ]]; then
	echo "Replacing existing ${TARGET}..."
	rm -rf "$TARGET"
fi

ditto "dist/${APP_NAME}.app" "$TARGET"
echo "Installed ${TARGET}"
echo "Spotlight may take up to a minute to index the app."
