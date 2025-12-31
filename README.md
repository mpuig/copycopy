# CopyCopy 📋 — Double ⌘C, instant actions.

A native macOS 14+ menu bar utility that shows contextual actions when you press ⌘C twice quickly. Copy something, double-tap ⌘C, and get instant access to relevant actions based on what's in your clipboard.

<!-- <img src="screenshot.png" alt="CopyCopy menu screenshot" width="520" /> -->

## Features

- **Double ⌘C trigger** — Configurable threshold (default 280ms) to detect double copy.
- **Context-aware suggestions** — Different actions for URLs, text, images, and files.
- **Custom actions** — Create your own actions with template variables.
- **Action types** — Open URL, run shell commands, or open apps with pasted text.
- **Content filtering** — Show actions only for specific content types.
- **Template variables** — Use `{text}`, `{text:encoded}`, `{text:trimmed}`, `{charcount}`, `{linecount}`.
- **Privacy-first** — Reads clipboard without modifying it; doesn't persist clipboard contents.
- **Native SwiftUI** — Modern MenuBarExtra with minimal resource usage.

## Install

### Requirements
- macOS 14+ (Sonoma)
- Apple Silicon (arm64) and Intel (x86_64)

### Option A: Download Release
1. Download the latest zip from [GitHub Releases](https://github.com/mpuig/copycopy/releases).
2. Unzip and move `CopyCopy.app` to `/Applications`.
3. Open it (first run: right-click → Open).
4. Grant Accessibility permission when prompted.

### Option B: Build from Source
```bash
git clone https://github.com/mpuig/copycopy.git
cd copycopy
./build.sh
open dist/CopyCopy.app
```

## Permissions

CopyCopy needs **Accessibility** permission to observe global ⌘C via an event tap.

1. System Settings → Privacy & Security → Accessibility → enable **CopyCopy**
2. If it still doesn't trigger, also enable:
   - System Settings → Privacy & Security → Input Monitoring → enable **CopyCopy**

The app includes shortcuts to open these settings pages from the menu.

## Usage

1. Press **⌘C twice quickly** (within 280ms) — the menu appears with contextual actions
2. Click an action to execute it, or press Escape to dismiss

That's it. Double ⌘C on any selected text, URL, file, or image to see relevant actions.

### Built-in Actions

Based on clipboard content, you'll see relevant actions like:
- **URLs**: Open URL, Open in Safari
- **Text**: Search the web, Look up in Dictionary, Summarize with ChatGPT
- **Files**: Open file, Reveal in Finder, Copy path
- **Images**: Save as PNG

### Custom Actions

Create your own actions in Settings → Actions:

| Template | Description |
|----------|-------------|
| `https://google.com/search?q={text:encoded}` | Search Google |
| `https://translate.google.com/?text={text:encoded}` | Translate text |
| `echo "{text}" \| pbcopy` | Shell command example |
| `Summarize this: {text}` | ChatGPT prompt (Open App) |

## Settings

Access settings from the menu bar icon → Settings:

- **General** — Start at login, double-copy threshold, popover behavior
- **Actions** — Create, edit, and manage custom actions
- **About** — Version info and update checks
- **Debug** — Diagnostic information (enable in General)

## Build & Development

```bash
# Build release app bundle
./build.sh

# Dev loop: rebuild + relaunch
./scripts/compile_and_run.sh

# Build debug binary only
swift build
.build/debug/CopyCopy
```

## Architecture

```
Sources/
├── Main.swift                 # SwiftUI App entry point
├── AppModel.swift             # Core app state and clipboard monitoring
├── Actions/                   # Custom actions model and store
├── Clipboard/                 # Event tap, pasteboard monitor, classifier
├── Settings/                  # Settings window and panes
├── Suggestions/               # Built-in suggestion engine
└── UI/                        # Menu content and views
```

## Privacy

- **No network requests** except for Sparkle update checks (optional).
- **No clipboard history** — Content is only held in memory during the current session.
- **No telemetry** — What you copy stays on your machine.

## Inspiration

- 🎚️ [CodexBar](https://github.com/steipete/CodexBar) — Menu bar app for AI provider usage tracking.
- 🔊 [AudioPriorityBar](https://github.com/tobi/AudioPriorityBar) — Menu bar app that automatically manages audio device priorities.

## License

MIT
