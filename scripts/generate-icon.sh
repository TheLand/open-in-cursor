#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CURSOR_ICNS="/Applications/Cursor.app/Contents/Resources/Cursor.icns"
WORK="assets/icon-work"
ICONSET="assets/AppIcon.iconset"
OUTPUT="assets/AppIcon.icns"

if [[ ! -f "$CURSOR_ICNS" ]]; then
	echo "Cursor.app icon not found at ${CURSOR_ICNS}" >&2
	exit 1
fi

rm -rf "$WORK" "$ICONSET"
mkdir -p "$WORK" "$ICONSET"

sips -s format png "$CURSOR_ICNS" --out "$WORK/cursor-512.png" >/dev/null
sips -z 1024 1024 "$WORK/cursor-512.png" --out "$WORK/cursor-1024.png" >/dev/null

swift "$ROOT/scripts/render-open-badge.swift" "$WORK/open-badge.png" "folder.fill"

BADGE_SIZE=300
MAGICK="$(command -v magick || command -v convert)"
"$MAGICK" "$WORK/open-badge.png" -resize "${BADGE_SIZE}x${BADGE_SIZE}" "$WORK/open-badge-resized.png"

# Bottom-right badge, slightly overlapping the edge.
"$MAGICK" "$WORK/cursor-1024.png" "$WORK/open-badge-resized.png" \
	-gravity southeast -geometry +20+20 -composite \
	"$WORK/composite-1024.png"

# Preview for quick review in the repo
cp "$WORK/composite-1024.png" "$ROOT/assets/icon-preview.png"

add_icon_size() {
	local size="$1"
	local name="$2"
	local src="$WORK/composite-1024.png"
	local out="$ICONSET/${name}.png"

	if [[ "$size" -eq 1024 ]]; then
		cp "$src" "$out"
	else
		sips -z "$size" "$size" "$src" --out "$out" >/dev/null
	fi
}

add_icon_size 16  icon_16x16
add_icon_size 32  icon_16x16@2x
add_icon_size 32  icon_32x32
add_icon_size 64  icon_32x32@2x
add_icon_size 128 icon_128x128
add_icon_size 256 icon_128x128@2x
add_icon_size 256 icon_256x256
add_icon_size 512 icon_256x256@2x
add_icon_size 512 icon_512x512
add_icon_size 1024 icon_512x512@2x

iconutil -c icns "$ICONSET" -o "$OUTPUT"
rm -rf "$WORK" "$ICONSET"

echo "Generated ${OUTPUT}"
