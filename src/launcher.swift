import AppKit
import Foundation

enum PermissionAlertAction: Equatable {
	case requestPermission
	case openSettings
	case cancel
}

enum GatekeeperAlertAction: Equatable {
	case openPrivacySecurity
	case continueLaunch
	case cancel
}

enum LauncherUI {
	static let automationSettingsURLs = [
		"x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Automation",
		"x-apple.systempreferences:com.apple.preference.security?Privacy_Automation",
	]

	static let automationGuideTitle = "Finder permission required"

	static let automationGuideMessage = """
	macOS must allow Open in Cursor to read the current Finder folder.

	Option A — recommended
	1. Click "Request Permission"
	2. In the system dialog, click OK or Allow
	3. If prompted, enable Finder

	Option B — if no system dialog appears
	1. Click "Request Permission" once
	2. Then click "Open Settings"
	3. Under Automation, find "Open in Cursor" and enable Finder

	Note: "Open in Cursor" only appears in Automation after you click "Request Permission".
	"""

	static func prepareForPermissionRequest() {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}

	static func openSystemSettings(
		urls: [String],
		workspace: NSWorkspace = .shared
	) -> Bool {
		for urlString in urls {
			guard let url = URL(string: urlString) else { continue }
			if workspace.open(url) {
				return true
			}
		}
		return false
	}

	static func openAutomationSettings(
		workspace: NSWorkspace = .shared,
		urls: [String] = automationSettingsURLs
	) -> Bool {
		openSystemSettings(urls: urls, workspace: workspace)
	}

	static func openPrivacySecuritySettings(
		workspace: NSWorkspace = .shared,
		urls: [String] = LauncherCore.privacySecuritySettingsURLs
	) -> Bool {
		openSystemSettings(urls: urls, workspace: workspace)
	}

	static func shouldShowGatekeeperGuide(
		bundlePath: String = Bundle.main.bundlePath,
		hasQuarantine: (String) -> Bool = { LauncherCore.hasQuarantineAttribute(at: $0) }
	) -> Bool {
		hasQuarantine(bundlePath)
	}

	@MainActor
	static func showGatekeeperGuideAlert() -> GatekeeperAlertAction {
		prepareForPermissionRequest()

		let alert = NSAlert()
		alert.messageText = LauncherCore.gatekeeperGuideTitle
		alert.informativeText = LauncherCore.gatekeeperGuideMessage
		alert.alertStyle = .warning
		alert.addButton(withTitle: "Open Privacy & Security")
		alert.addButton(withTitle: "Continue")
		alert.addButton(withTitle: "Cancel")

		switch alert.runModal() {
		case .alertFirstButtonReturn:
			return .openPrivacySecurity
		case .alertSecondButtonReturn:
			return .continueLaunch
		default:
			return .cancel
		}
	}

	@MainActor
	static func handleGatekeeperGuideIfNeeded() -> Bool {
		guard shouldShowGatekeeperGuide() else { return true }

		while true {
			switch showGatekeeperGuideAlert() {
			case .openPrivacySecurity:
				if !openPrivacySecuritySettings() {
					showError(
						"Unable to open System Settings. Open Privacy & Security → Security manually."
					)
				}
			case .continueLaunch:
				return true
			case .cancel:
				return false
			}
		}
	}

	@MainActor
	static func showAutomationPermissionAlert() -> PermissionAlertAction {
		prepareForPermissionRequest()

		let alert = NSAlert()
		alert.messageText = automationGuideTitle
		alert.informativeText = automationGuideMessage
		alert.alertStyle = .informational
		alert.addButton(withTitle: "Request Permission")
		alert.addButton(withTitle: "Open Settings")
		alert.addButton(withTitle: "Cancel")

		switch alert.runModal() {
		case .alertFirstButtonReturn:
			return .requestPermission
		case .alertSecondButtonReturn:
			return .openSettings
		default:
			return .cancel
		}
	}

	@MainActor
	static func showSettingsHintAfterRequest() {
		let alert = NSAlert()
		alert.messageText = "Permission not active yet"
		alert.informativeText = """
		If you did not see a system dialog, open Settings → Privacy & Security → Automation and enable Finder for Open in Cursor.

		If Open in Cursor is not listed, click "Request Permission" again and then reopen Settings.
		"""
		alert.alertStyle = .warning
		alert.addButton(withTitle: "Open Settings")
		alert.addButton(withTitle: "OK")
		if alert.runModal() == .alertFirstButtonReturn {
			_ = openAutomationSettings()
		}
	}
}

@MainActor
func showError(_ message: String) {
	LauncherUI.prepareForPermissionRequest()
	let alert = NSAlert()
	alert.messageText = message
	alert.alertStyle = .critical
	alert.addButton(withTitle: "OK")
	alert.runModal()
}

@MainActor
func openFolderInCursor(from folderPath: String) {
	guard let cursorBin = LauncherCore.resolveCursorCLI() else {
		showError(LauncherCore.cursorNotFoundMessage)
		return
	}

	do {
		try openInCursor(folderPath: folderPath, cursorBin: cursorBin)
	} catch LauncherError.cursorLaunchFailed {
		showError(LauncherCore.cursorLaunchFailedMessage)
	} catch {
		showError(LauncherCore.cursorLaunchFailedMessage)
	}
}

@MainActor
func handleFinderPermissionDenied() {
	LauncherUI.prepareForPermissionRequest()

	while true {
		switch LauncherUI.showAutomationPermissionAlert() {
		case .requestPermission:
			do {
				let folderPath = try getFinderFolderPath()
				openFolderInCursor(from: folderPath)
				return
			} catch LauncherError.finderPermissionDenied {
				LauncherUI.showSettingsHintAfterRequest()
			} catch LauncherError.noFinderWindow {
				showError(LauncherCore.noFinderWindowMessage)
				return
			} catch LauncherError.finderReadFailed {
				showError(LauncherCore.finderReadFailedMessage)
				return
			} catch {
				showError(LauncherCore.finderReadFailedMessage)
				return
			}
		case .openSettings:
			// Re-register with macOS before opening Settings so the app appears in Automation.
			_ = try? getFinderFolderPath()
			if !LauncherUI.openAutomationSettings() {
				showError("Unable to open System Settings. Open Privacy & Security → Automation manually.")
			}
		case .cancel:
			return
		}
	}
}

@MainActor
func runLauncher() {
	guard LauncherUI.handleGatekeeperGuideIfNeeded() else { return }

	do {
		let folderPath = try getFinderFolderPath()
		openFolderInCursor(from: folderPath)
	} catch LauncherError.noFinderWindow {
		showError(LauncherCore.noFinderWindowMessage)
	} catch LauncherError.finderPermissionDenied {
		handleFinderPermissionDenied()
	} catch LauncherError.finderReadFailed {
		showError(LauncherCore.finderReadFailedMessage)
	} catch LauncherError.cursorLaunchFailed {
		showError(LauncherCore.cursorLaunchFailedMessage)
	} catch {
		showError(LauncherCore.finderReadFailedMessage)
	}
}

@main
@MainActor
struct OpenInCursorApp {
	static func main() {
		NSApplication.shared.setActivationPolicy(.accessory)
		runLauncher()
	}
}
