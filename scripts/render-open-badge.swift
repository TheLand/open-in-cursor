import AppKit

let outputPath = CommandLine.arguments[1]
let symbolName = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "folder.fill"
let pointSize: CGFloat = 128

let canvasSize = NSSize(width: 320, height: 320)
let image = NSImage(size: canvasSize, flipped: false) { rect in
	let inset: CGFloat = 18
	let badgeRect = rect.insetBy(dx: inset, dy: inset)
	let cornerRadius = badgeRect.width * 0.225

	// Light shadow
	NSColor.black.withAlphaComponent(0.22).setFill()
	let shadowRect = badgeRect.offsetBy(dx: 0, dy: -4)
	NSBezierPath(roundedRect: shadowRect, xRadius: cornerRadius, yRadius: cornerRadius).fill()

	// macOS-style squircle, Finder-like yellow
	NSColor(calibratedRed: 0.98, green: 0.74, blue: 0.18, alpha: 1).setFill()
	NSBezierPath(roundedRect: badgeRect, xRadius: cornerRadius, yRadius: cornerRadius).fill()

	NSColor.white.withAlphaComponent(0.35).setStroke()
	let border = NSBezierPath(roundedRect: badgeRect.insetBy(dx: 1.5, dy: 1.5), xRadius: cornerRadius, yRadius: cornerRadius)
	border.lineWidth = 2
	border.stroke()

	let symbolConfig = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
		.applying(NSImage.SymbolConfiguration(paletteColors: [NSColor.white]))

	guard let symbol = NSImage(
		systemSymbolName: symbolName,
		accessibilityDescription: "Folder"
	)?.withSymbolConfiguration(symbolConfig) else {
		fputs("Failed to load SF Symbol: \(symbolName)\n", stderr)
		return false
	}

	let symbolSide = badgeRect.width * 0.56
	let symbolRect = NSRect(
		x: badgeRect.midX - symbolSide / 2,
		y: badgeRect.midY - symbolSide / 2 - 2,
		width: symbolSide,
		height: symbolSide
	)
	symbol.draw(in: symbolRect)
	return true
}

guard
	let tiff = image.tiffRepresentation,
	let rep = NSBitmapImageRep(data: tiff),
	let png = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
else {
	fputs("Failed to encode badge PNG\n", stderr)
	exit(1)
}

do {
	try png.write(to: URL(fileURLWithPath: outputPath))
} catch {
	fputs("Failed to write badge PNG\n", stderr)
	exit(1)
}
