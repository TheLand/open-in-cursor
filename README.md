<p align="center">
  <img src="assets/icon-preview.png" width="128" alt="Open in Cursor" />
</p>

<p align="center">
  <strong>Open in Cursor</strong>
</p>

<p align="center">
  macOS utility that opens the current Finder folder in Cursor in a new window.
</p>

<p align="center">
  <a href="https://github.com/TheLand/open-in-cursor/releases/latest/download/OpenInCursor.dmg">
    <img src="https://img.shields.io/github/v/release/TheLand/open-in-cursor?label=Download&sort=semver&color=007AFF" alt="Download latest" />
  </a>
  <img src="https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-native-F05138?logo=swift&logoColor=white" alt="Swift" />
  <img src="https://img.shields.io/badge/Cursor-required-000000?logo=cursor&logoColor=white" alt="Cursor" />
</p>

<p align="center">
  <em>Download the .dmg, drag it to Applications, launch from Spotlight.</em>
</p>

---

## Open in Cursor

Open in Cursor is a lightweight macOS app that bridges Finder and Cursor: open a folder in Finder, launch the app from Spotlight, and Cursor opens that directory in a **new window**.

### How it works

The app reads the front Finder window path and invokes the `cursor` CLI:

- **Spotlight**: launch with `Cmd+Space` → "Open in Cursor"
- **Finder automation**: macOS asks for permission to control Finder (one-time)
- **Cursor CLI**: opens the folder with `cursor -n <path>` (uses the CLI bundled inside Cursor.app when needed)

```mermaid
graph TB
    subgraph usage [Daily workflow]
        Finder["Finder — folder open"]
        Spotlight["Spotlight Cmd+Space"]
        App["Open in Cursor.app"]
        CursorCLI["cursor -n path"]
        Cursor["Cursor — new window"]
    end

    Finder --> Spotlight
    Spotlight --> App
    App -->|"AppleScript"| Finder
    App --> CursorCLI
    CursorCLI --> Cursor
```

### Features

- **Spotlight**: install to `/Applications`, searchable immediately
- **New Cursor window**: uses `-n` instead of reusing an existing window
- **Universal binary**: native on Apple Silicon and Intel
- **Permission guide**: in-app dialog with **Request Permission** and **Open Settings**
- **First-launch guide**: in-app **Open Privacy & Security** when Gatekeeper quarantine is detected
- **Team distribution**: `.dmg` published on GitHub Releases
- **CI/CD**: GitHub Actions tests on every push; **automatic release on every tag push**

## Quickstart

### Download

**[Download latest (OpenInCursor.dmg)](https://github.com/TheLand/open-in-cursor/releases/latest/download/OpenInCursor.dmg)**

All releases: [github.com/TheLand/open-in-cursor/releases](https://github.com/TheLand/open-in-cursor/releases/latest)

Requirements: [macOS 13+](https://www.apple.com/macos/) · [Cursor](https://cursor.com) installed

### Installation

1. Open the downloaded `.dmg`
2. Drag **Open in Cursor** to **Applications**

### First launch (macOS security)

Open in Cursor is distributed as an open-source `.dmg` and is **not notarized** by Apple. On first launch, macOS may show:

> *Apple cannot verify that Open in Cursor is free of malware…*

This is **Gatekeeper**, not a sign of malware. Until the app is signed and notarized (see [Development](docs/development.md#distribution-limitations)), every user must approve it once.

**If macOS blocks the app before it opens**, the in-app help is not available yet. Use one of these methods first:

| Method | Steps |
| --- | --- |
| **Right-click Open** (recommended) | Applications → right-click **Open in Cursor** → **Open** → confirm **Open** |
| **Privacy & Security** | After a blocked launch, open **System Settings → Privacy & Security → Security** → **Open Anyway** |
| **Terminal** | `xattr -cr "/Applications/Open in Cursor.app"` |

Open **Privacy & Security** from Terminal:

```bash
open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"
```

After the first successful launch, the app may show an in-app guide with **Open Privacy & Security** when the download quarantine flag is still present.

### Finder permission

On first use:

1. Click **Request Permission** in the app dialog
2. In the **macOS** system dialog, click **OK** or **Allow**
3. If needed, enable **Finder** under **System Settings → Privacy & Security → Automation**

> **Note:** "Open in Cursor" only appears in Automation **after** you click "Request Permission".

### Verify

1. Open Finder on a working folder
2. `Cmd+Space` → type **Open in Cursor** → Enter
3. Cursor opens in a new window on that folder

No extra setup is required if Cursor is installed in **Applications**. The optional `cursor` shell command is only needed for terminal use.

## Troubleshooting

| Problem | Solution |
| --- | --- |
| "No Finder window is open" | Open at least one Finder window on a folder |
| "Cursor not found" | Install [Cursor](https://cursor.com) to Applications |
| Finder permission denied | **Request Permission** → Allow in the system dialog → **Open Settings** |
| Open in Cursor missing in Automation | Click **Request Permission** first, then reopen Settings |
| Stale permissions (`env`, `bash`) | Disable those entries in Automation, or run `tccutil reset AppleEvents com.openincursor.app` and relaunch |
| App not in Spotlight | Wait ~1 minute after install, or restart Finder |
| macOS blocks the app (Gatekeeper) | Right-click → **Open** first; then **Privacy & Security → Security → Open Anyway**, or `xattr -cr "/Applications/Open in Cursor.app"` |
| In-app **Open Privacy & Security** missing | macOS blocked launch before the app started — use the table above first |

## Documentation

- **[Development](docs/development.md)** — build, test, Git hooks, releases, contributing
- **[Changelog](CHANGELOG.md)** — release notes and version history
- **README** (this file) — installation and troubleshooting

### Updates

Download the [latest release](https://github.com/TheLand/open-in-cursor/releases/latest/download/OpenInCursor.dmg) and replace the app in **Applications**.

### Contact

Open a [GitHub issue](https://github.com/TheLand/open-in-cursor/issues) for bugs or feature requests.

## Acknowledgments

Inspired by [OpenInCode](https://github.com/sozercan/openincode) — a macOS Finder toolbar app to open the current folder in Visual Studio Code.
