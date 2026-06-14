import AppKit
import Foundation

enum LauncherError: Error, Equatable {
	case noFinderWindow
	case finderPermissionDenied
	case finderReadFailed
	case cursorLaunchFailed
	case cursorNotFound
}

enum LauncherCore {
	static let finderAppleScriptSource = """
tell application "Finder"
	if (count of windows) is 0 then error "NO_FINDER_WINDOW" number -1
	try
		return POSIX path of (folder of front window as alias)
	on error
		try
			return POSIX path of (target of front window as alias)
		on error
			return POSIX path of (insertion location as alias)
		end try
	end try
end tell
"""

	static let cursorCandidatePaths = [
		"/usr/local/bin/cursor",
		"/opt/homebrew/bin/cursor",
	]

	static let cursorNotFoundMessage =
		"Cursor CLI not found. Open Cursor, press Cmd+Shift+P, and select \"Shell Command: Install 'cursor' command in PATH\"."

	static let noFinderWindowMessage =
		"No Finder window is open. Open a folder in Finder and try again."

	static let finderReadFailedMessage =
		"Unable to read the Finder folder."

	static let cursorLaunchFailedMessage =
		"Unable to launch Cursor. Make sure Cursor is installed and the cursor command is available."

	static func normalizeFolderPath(_ raw: String) -> String? {
		let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}

	static func mapFinderScriptError(message: String, number: Int = 0) -> LauncherError {
		if message.contains("NO_FINDER_WINDOW") {
			return .noFinderWindow
		}
		if number == -1743
			|| message.localizedCaseInsensitiveContains("not authorized")
			|| message.localizedCaseInsensitiveContains("non autorizzat")
		{
			return .finderPermissionDenied
		}
		return .finderReadFailed
	}

	static func extractString(from descriptor: NSAppleEventDescriptor) -> String? {
		if let value = descriptor.stringValue {
			return value
		}
		let unicodeText: DescType = 0x7574_3136 // 'ut16'
		return descriptor.coerce(toDescriptorType: unicodeText)?.stringValue
	}

	static func resolveCursorCLI(
		isExecutable: (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) },
		pathEnvironment: String = ProcessInfo.processInfo.environment["PATH"] ?? ""
	) -> String? {
		for path in cursorCandidatePaths where isExecutable(path) {
			return path
		}

		for entry in pathEnvironment.split(separator: ":", omittingEmptySubsequences: true) {
			let candidate = "\(entry)/cursor"
			if isExecutable(candidate) {
				return candidate
			}
		}

		return nil
	}

	static func launchArguments(folderPath: String) -> [String] {
		["-n", folderPath]
	}

	static func launchExecutableURL(cursorBin: String) -> URL {
		URL(fileURLWithPath: cursorBin)
	}
}

func getFinderFolderPath() throws -> String {
	var errorInfo: NSDictionary?
	guard let script = NSAppleScript(source: LauncherCore.finderAppleScriptSource) else {
		throw LauncherError.finderReadFailed
	}

	let result = script.executeAndReturnError(&errorInfo)
	if let errorInfo {
		let message = errorInfo[NSAppleScript.errorMessage] as? String ?? ""
		let number = errorInfo[NSAppleScript.errorNumber] as? Int ?? 0
		throw LauncherCore.mapFinderScriptError(message: message, number: number)
	}

	guard let path = LauncherCore.extractString(from: result).flatMap(LauncherCore.normalizeFolderPath) else {
		throw LauncherError.finderReadFailed
	}

	return path
}

func openInCursor(folderPath: String, cursorBin: String) throws {
	let process = Process()
	process.executableURL = LauncherCore.launchExecutableURL(cursorBin: cursorBin)
	process.arguments = LauncherCore.launchArguments(folderPath: folderPath)
	process.standardOutput = FileHandle.nullDevice
	process.standardError = FileHandle.nullDevice

	do {
		try process.run()
	} catch {
		throw LauncherError.cursorLaunchFailed
	}
}
