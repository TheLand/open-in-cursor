import XCTest
@testable import OpenInCursor

final class LauncherCoreTests: XCTestCase {
	func testNormalizeFolderPathTrimsWhitespace() {
		XCTAssertEqual(LauncherCore.normalizeFolderPath(" /Users/test/ \n"), "/Users/test/")
	}

	func testNormalizeFolderPathRejectsEmpty() {
		XCTAssertNil(LauncherCore.normalizeFolderPath("   "))
		XCTAssertNil(LauncherCore.normalizeFolderPath("\n"))
	}

	func testMapFinderScriptErrorNoWindow() {
		XCTAssertEqual(
			LauncherCore.mapFinderScriptError(message: "NO_FINDER_WINDOW"),
			.noFinderWindow
		)
	}

	func testMapFinderScriptErrorPermissionDeniedByNumber() {
		XCTAssertEqual(
			LauncherCore.mapFinderScriptError(message: "error", number: -1743),
			.finderPermissionDenied
		)
	}

	func testMapFinderScriptErrorPermissionDeniedByMessage() {
		XCTAssertEqual(
			LauncherCore.mapFinderScriptError(message: "Not authorized to send Apple events to Finder."),
			.finderPermissionDenied
		)
	}

	func testMapFinderScriptErrorGeneric() {
		XCTAssertEqual(
			LauncherCore.mapFinderScriptError(message: "something else"),
			.finderReadFailed
		)
	}

	func testResolveCursorCLIUsesKnownPathsFirst() {
		let resolved = LauncherCore.resolveCursorCLI(
			isExecutable: { $0 == "/opt/homebrew/bin/cursor" },
			pathEnvironment: "/usr/bin:/bin"
		)
		XCTAssertEqual(resolved, "/opt/homebrew/bin/cursor")
	}

	func testResolveCursorCLIFallsBackToPathEnvironment() {
		let resolved = LauncherCore.resolveCursorCLI(
			isExecutable: { $0 == "/custom/bin/cursor" },
			pathEnvironment: "/custom/bin:/usr/bin"
		)
		XCTAssertEqual(resolved, "/custom/bin/cursor")
	}

	func testResolveCursorCLIFallsBackToBundledCLI() {
		let resolved = LauncherCore.resolveCursorCLI(
			isExecutable: { $0 == "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" },
			pathEnvironment: "/usr/bin",
			appBundleLocator: { nil }
		)
		XCTAssertEqual(resolved, "/Applications/Cursor.app/Contents/Resources/app/bin/cursor")
	}

	func testResolveCursorCLIFallsBackToLocatedAppBundle() {
		let resolved = LauncherCore.resolveCursorCLI(
			isExecutable: { $0 == "/Users/test/Apps/Cursor.app/Contents/Resources/app/bin/cursor" },
			pathEnvironment: "/usr/bin",
			appBundleLocator: { "/Users/test/Apps/Cursor.app" }
		)
		XCTAssertEqual(resolved, "/Users/test/Apps/Cursor.app/Contents/Resources/app/bin/cursor")
	}

	func testResolveCursorCLIReturnsNilWhenMissing() {
		XCTAssertNil(
			LauncherCore.resolveCursorCLI(
				isExecutable: { _ in false },
				pathEnvironment: "/usr/bin",
				appBundleLocator: { nil }
			)
		)
	}

	func testLaunchArgumentsOpenNewWindow() {
		XCTAssertEqual(
			LauncherCore.launchArguments(folderPath: "/tmp/project"),
			["-n", "/tmp/project"]
		)
	}

	func testLaunchExecutableURL() {
		XCTAssertEqual(
			LauncherCore.launchExecutableURL(cursorBin: "/usr/local/bin/cursor").path,
			"/usr/local/bin/cursor"
		)
	}

	func testFinderAppleScriptSourceContainsFallbacks() {
		XCTAssertTrue(LauncherCore.finderAppleScriptSource.contains("NO_FINDER_WINDOW"))
		XCTAssertTrue(LauncherCore.finderAppleScriptSource.contains("folder of front window"))
		XCTAssertTrue(LauncherCore.finderAppleScriptSource.contains("insertion location"))
	}

	func testAutomationSettingsURLsAreConfigured() {
		XCTAssertFalse(LauncherUI.automationSettingsURLs.isEmpty)
		XCTAssertTrue(LauncherUI.automationSettingsURLs.allSatisfy { $0.hasPrefix("x-apple.systempreferences:") })
	}

	func testPrivacySecuritySettingsURLsAreConfigured() {
		XCTAssertFalse(LauncherCore.privacySecuritySettingsURLs.isEmpty)
		XCTAssertTrue(
			LauncherCore.privacySecuritySettingsURLs.allSatisfy { $0.hasPrefix("x-apple.systempreferences:") }
		)
	}

	func testHasQuarantineAttributeDetectsQuarantine() {
		XCTAssertTrue(
			LauncherCore.hasQuarantineAttribute(
				at: "/Applications/Open in Cursor.app",
				xattrLister: { _ in "com.apple.quarantine: 0083;..." }
			)
		)
	}

	func testHasQuarantineAttributeReturnsFalseWithoutQuarantine() {
		XCTAssertFalse(
			LauncherCore.hasQuarantineAttribute(
				at: "/Applications/Open in Cursor.app",
				xattrLister: { _ in "com.apple.provenance:" }
			)
		)
	}

	func testShouldShowGatekeeperGuideWhenQuarantined() {
		XCTAssertTrue(
			LauncherUI.shouldShowGatekeeperGuide(bundlePath: "/tmp/Open in Cursor.app") { _ in true }
		)
	}

	func testShouldShowGatekeeperGuideWhenClean() {
		XCTAssertFalse(
			LauncherUI.shouldShowGatekeeperGuide(bundlePath: "/tmp/Open in Cursor.app") { _ in false }
		)
	}
}
