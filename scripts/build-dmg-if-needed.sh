#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
DMG="dist/OpenInCursor-${VERSION}.dmg"

SOURCE_PATHS=(
	VERSION
	build.sh
	package.sh
	Package.swift
	src/LauncherCore.swift
	src/launcher.swift
	src/Info.plist.template
	scripts/generate-icon.sh
	scripts/render-open-badge.swift
	Tests/LauncherCoreTests.swift
)

needs_rebuild() {
	if [[ ! -f "$DMG" ]]; then
		return 0
	fi

	local dmg_mtime path_mtime
	dmg_mtime="$(stat -f %m "$DMG")"

	for path in "${SOURCE_PATHS[@]}"; do
		if [[ ! -e "$path" ]]; then
			continue
		fi
		path_mtime="$(stat -f %m "$path")"
		if [[ "$path_mtime" -gt "$dmg_mtime" ]]; then
			return 0
		fi
	done

	if [[ -f assets/AppIcon.icns ]]; then
		path_mtime="$(stat -f %m assets/AppIcon.icns)"
		if [[ "$path_mtime" -gt "$dmg_mtime" ]]; then
			return 0
		fi
	fi

	return 1
}

if needs_rebuild; then
	echo "Rebuilding Open in Cursor v${VERSION}..."
	chmod +x build.sh package.sh
	./build.sh
	./package.sh
else
	echo "DMG up to date: ${DMG}"
fi
