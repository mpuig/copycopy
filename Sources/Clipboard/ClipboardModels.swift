import Cocoa

enum ClipboardContentKind: String {
    case url
    case fileURLs
    case image
    case plainText
    case richText
    case unknown
}

enum SourceAppContext {
    case terminal
    case ide
    case browser
    case other

    init(bundleIdentifier: String?, appName: String?) {
        if TerminalAppIdentifiers.isTerminal(bundleIdentifier: bundleIdentifier, appName: appName) {
            self = .terminal
        } else if IDEAppIdentifiers.isIDE(bundleIdentifier: bundleIdentifier, appName: appName) {
            self = .ide
        } else if BrowserAppIdentifiers.isBrowser(bundleIdentifier: bundleIdentifier, appName: appName) {
            self = .browser
        } else {
            self = .other
        }
    }
}

struct ClipboardSnapshot: Sendable {
    let changeCount: Int
    let kind: ClipboardContentKind
    let summary: String

    let url: URL?
    let fileURLs: [URL]?
    let plainText: String?
    let richTextType: NSPasteboard.PasteboardType?

    init(
        changeCount: Int,
        kind: ClipboardContentKind,
        summary: String,
        url: URL? = nil,
        fileURLs: [URL]? = nil,
        plainText: String? = nil,
        richTextType: NSPasteboard.PasteboardType? = nil
    ) {
        self.changeCount = changeCount
        self.kind = kind
        self.summary = summary
        self.url = url
        self.fileURLs = fileURLs
        self.plainText = plainText
        self.richTextType = richTextType
    }
}

struct ClipboardContext: Sendable {
    let copyEvent: CopyKeyEvent?
    let snapshot: ClipboardSnapshot
    let capturedAt: TimeInterval

    var sourceAppContext: SourceAppContext {
        SourceAppContext(bundleIdentifier: copyEvent?.bundleID, appName: copyEvent?.appName)
    }
}

