import Foundation

enum TerminalAppIdentifiers {
    static let exactBundleIdentifiers: Set<String> = [
        "com.apple.terminal",
        "com.googlecode.iterm2",
        "com.mitchellh.ghostty",
        "dev.warp.warp",
        "dev.warp.warp-stable",
        "com.github.wez.wezterm",
        "org.alacritty",
        "co.zeit.hyper",
        "net.kovidgoyal.kitty",
    ]

    static let bundleIdentifierPrefixes: [String] = [
        "com.googlecode.iterm2",
    ]

    static let nameHints: [String] = [
        "terminal",
        "iterm",
        "ghostty",
        "warp",
        "wezterm",
        "alacritty",
        "hyper",
        "kitty",
    ]

    static func isTerminal(bundleIdentifier: String?, appName: String?) -> Bool {
        if let bundleIdentifier {
            let lower = bundleIdentifier.lowercased()
            if Self.exactBundleIdentifiers.contains(lower) {
                return true
            }
            if Self.bundleIdentifierPrefixes.contains(where: { lower.hasPrefix($0) }) {
                return true
            }
        }

        let name = (appName ?? "").lowercased()
        return Self.nameHints.contains { name.contains($0) }
    }
}

enum IDEAppIdentifiers {
    static let exactBundleIdentifiers: Set<String> = [
        "com.apple.dt.xcode",
        "com.microsoft.vscode",
        "com.jetbrains.intellij",
        "com.jetbrains.pycharm",
        "com.jetbrains.webstorm",
        "com.jetbrains.goland",
        "com.jetbrains.rubymine",
        "com.jetbrains.clion",
        "com.jetbrains.rider",
        "com.jetbrains.datagrip",
        "com.jetbrains.fleet",
        "com.sublimetext.4",
        "com.sublimetext.3",
        "com.panic.nova",
        "com.barebones.bbedit",
        "abnerworks.typora",
        "md.obsidian",
        "com.cursor.cursor",
    ]

    static let bundleIdentifierPrefixes: [String] = [
        "com.jetbrains.",
    ]

    static let nameHints: [String] = [
        "xcode",
        "vscode",
        "visual studio code",
        "intellij",
        "pycharm",
        "webstorm",
        "goland",
        "rubymine",
        "clion",
        "rider",
        "sublime",
        "nova",
        "bbedit",
        "cursor",
        "zed",
    ]

    static func isIDE(bundleIdentifier: String?, appName: String?) -> Bool {
        if let bundleIdentifier {
            let lower = bundleIdentifier.lowercased()
            if Self.exactBundleIdentifiers.contains(lower) {
                return true
            }
            if Self.bundleIdentifierPrefixes.contains(where: { lower.hasPrefix($0) }) {
                return true
            }
        }

        let name = (appName ?? "").lowercased()
        return Self.nameHints.contains { name.contains($0) }
    }
}

enum BrowserAppIdentifiers {
    static let exactBundleIdentifiers: Set<String> = [
        "com.apple.safari",
        "com.google.chrome",
        "org.mozilla.firefox",
        "com.microsoft.edgemac",
        "com.brave.browser",
        "com.operasoftware.opera",
        "com.vivaldi.vivaldi",
        "company.thebrowser.browser",
    ]

    static func isBrowser(bundleIdentifier: String?, appName: String?) -> Bool {
        if let bundleIdentifier {
            let lower = bundleIdentifier.lowercased()
            if Self.exactBundleIdentifiers.contains(lower) {
                return true
            }
        }

        let name = (appName ?? "").lowercased()
        return ["safari", "chrome", "firefox", "edge", "brave", "opera", "vivaldi", "arc"].contains { name.contains($0) }
    }
}
