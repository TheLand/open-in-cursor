// swift-tools-version: 5.9
import PackageDescription

let package = Package(
	name: "OpenInCursor",
	platforms: [.macOS(.v13)],
	products: [
		.executable(name: "OpenInCursor", targets: ["OpenInCursor"]),
	],
	targets: [
		.executableTarget(
			name: "OpenInCursor",
			path: "src",
			exclude: ["Info.plist.template"]
		),
		.testTarget(
			name: "OpenInCursorTests",
			dependencies: ["OpenInCursor"],
			path: "Tests"
		),
	]
)
