# DockMaster Pro

A powerful, customizable multi-row Dock replacement for macOS.

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

[English](README.md) | [中文](README_zh.md)

## Features

### Custom Dock Overlay
- **Multi-row / Multi-column layout** — Display icons in a grid, not just a single line
- **Three positions** — Bottom, Left, or Right edge of your screen
- **Configurable icon size** — 32px to 128px
- **Auto-hide** — Hide when not in use, show on mouse proximity
- **Scrollable overflow** — Smooth scrolling when content exceeds available space
- **Recent Apps** — Toggleable section showing currently running unpinned apps

### Dock Sections
- **Multiple named sections** — Organize apps into logical groups
- **Add, rename, reorder, delete** — Full section management
- **Visual separators** — Clear boundaries between sections
- **Drag & drop** — Reorder sections and items intuitively

### Rich Animations
- **20 hover styles** — Bounce, Shake, Pulse, Flip 3D, Glitch, Tada, Heartbeat, and more
- **8 launch animations** — Scale, Fade, Slide, Pop, and more
- **7 quit animations** — Shrink, Fade, Dissolve, and more
- **Respects Reduce Motion** — Honors macOS accessibility settings

### Workspaces
- **Multiple workspaces** — Each with its own dock layout and pinned apps
- **Space binding** — Bind workspaces to macOS Spaces for automatic switching
- **Custom hotkeys** — Assign keyboard shortcuts (e.g. Cmd+Opt+1) for instant switching
- **Quick switch** — Switch via Menu Bar extra

### Theme Engine
- **3 built-in themes** — Dark, Light, and Minimal
- **Full theme editor** — Customize colors, corner radius, blur, shadows, icon padding
- **Import / Export** — Share themes as `.dmtheme` files
- **Custom icon packs** — Per-app icon overrides bundled with themes
- **Live preview** — See changes in real-time with a mini dock preview

### Quick Search
- **Spotlight-like search** — Search apps, files, documents, bookmarks, and recent items
- **Keyboard navigation** — Arrow keys to navigate, Enter to open
- **Recent items view** — Quick access when search field is empty
- **Global shortcut** — Open with Option+Space

### System Monitor Widget
- **CPU & Memory** — Mini ring charts with usage percentages
- **Network speed** — Real-time download/upload speed
- **Expandable** — Tap to see detailed metrics

### Native Dock Replacement
- **Hide macOS Dock** — Seamlessly replace the native Dock
- **Auto-restore** — Original Dock settings restored on app quit

### Menu Bar Integration
- **Menu Bar extra** — Configurable icon (Dock, Grid, Circle, Star)
- **Workspace switcher** — Quick access to all workspaces
- **Settings access** — One-click to open preferences

### Internationalization
- **4 languages** — English, Simplified Chinese, Traditional Chinese, Japanese
- **In-app language switch** — Change language without restarting

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (arm64)

## Installation

### From Release
Download the latest `.zip` from [Releases](https://github.com/qianmoQ/DockMaster/releases), unzip, and drag `DockMaster Pro.app` to your Applications folder.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/qianmoQ/DockMaster.git
cd DockMaster

# Release build
./build.sh

# Debug build
./build.sh --debug

# Build with code signing
./build.sh --sign "Developer ID Application: Your Name (TEAMID)"
```

The built app will be in `build/DockMaster Pro.app`.

## Permissions

DockMaster Pro requires the following permissions:

- **Accessibility** — Required to control the Dock process and manage other applications
- **Apple Events** — Required to launch and interact with other applications

Grant these in **System Settings > Privacy & Security > Accessibility**.

## Project Structure

```
DockMasterPro/
├── App/                    # Entry point & app delegate
├── Core/                   # Business logic engines
│   ├── DockEngine/         # Dock layout management
│   ├── ThemeEngine/        # Theme loading, editing, import/export
│   ├── WorkspaceManager/   # Workspace CRUD & switching
│   ├── SearchEngine/       # Global search controller
│   └── SystemMonitor/      # CPU, Memory, Network monitors
├── Features/               # UI feature modules
│   ├── DockOverlay/        # Main dock overlay UI
│   ├── QuickSearch/        # Spotlight-like search panel
│   ├── StatusWidget/       # System monitor widget
│   └── ContextMenu/        # Right-click context menus
├── Settings/               # Preferences UI & view models
├── Models/                 # Data models & preferences
├── Services/               # System integrations
├── Support/                # Localization, errors, logging
└── Extensions/             # SwiftUI & AppKit extensions
```

## License

MIT License. See [LICENSE](LICENSE) for details.
