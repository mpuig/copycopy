# Changelog

## 0.2.2 — 2025-12-31

### Fixes
- Escape inserted clipboard text when running `shellCommand` actions.

### Improvements
- Expand app-name detection for `openApp` templates (ChatGPT/Claude/Cursor/Copilot).
- Small refactors in clipboard entity detection and double-copy event tap constants.

### Developer
- Add SwiftPM test target and initial unit tests.

## 0.1.0 — Unreleased

Initial release of CopyCopy.

### Features
- **Double ⌘C trigger** — Press ⌘C twice quickly to show contextual actions.
- **Context-aware suggestions** — Different actions for URLs, text, images, and files.
- **Custom actions** — Create your own actions with template variables.
- **Action types** — Open URL, run shell commands, or open apps with pasted text.
- **Content filtering** — Show actions only for specific content types.
- **Template variables** — `{text}`, `{text:encoded}`, `{text:trimmed}`, `{charcount}`, `{linecount}`.
- **Settings window** — General, Actions, About, and Debug tabs.
- **Start at Login** — Launch automatically when macOS starts.
- **Native SwiftUI** — Modern MenuBarExtra with minimal resource usage.

### Built-in Actions
- URLs: Open URL, Open in Safari
- Text: Search the web, Look up in Dictionary, Summarize with ChatGPT
- Files: Open file, Reveal in Finder, Copy path
- Images: Save as PNG

### Requirements
- macOS 14+ (Sonoma)
- Apple Silicon and Intel supported
