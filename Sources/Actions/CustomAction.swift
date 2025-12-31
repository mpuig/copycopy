import Foundation

enum ActionType: String, Codable, CaseIterable, Identifiable {
    case openURL = "openURL"
    case shellCommand = "shellCommand"
    case openApp = "openApp"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openURL: return "Open URL"
        case .shellCommand: return "Run Shell Command"
        case .openApp: return "Open App"
        }
    }

    var systemImage: String {
        switch self {
        case .openURL: return "link"
        case .shellCommand: return "terminal"
        case .openApp: return "app"
        }
    }
}

enum ContentTypeFilter: String, Codable, CaseIterable, Identifiable {
    case any = "any"
    case text = "text"
    case url = "url"
    case image = "image"
    case files = "files"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .text: return "Text"
        case .url: return "URL"
        case .image: return "Image"
        case .files: return "Files"
        }
    }

    func matches(_ kind: ClipboardContentKind) -> Bool {
        switch self {
        case .any: return true
        case .text: return kind == .plainText || kind == .richText
        case .url: return kind == .url
        case .image: return kind == .image
        case .files: return kind == .fileURLs
        }
    }
}

struct CustomAction: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var actionType: ActionType
    var template: String
    var contentFilter: ContentTypeFilter
    var systemImage: String
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        actionType: ActionType = .openURL,
        template: String = "",
        contentFilter: ContentTypeFilter = .any,
        systemImage: String = "star",
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.actionType = actionType
        self.template = template
        self.contentFilter = contentFilter
        self.systemImage = systemImage
        self.isEnabled = isEnabled
    }

    func processTemplate(with text: String) -> String {
        var result = template
        result = result.replacingOccurrences(of: "{text}", with: text)
        result = result.replacingOccurrences(of: "{TEXT}", with: text)

        if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            result = result.replacingOccurrences(of: "{text:encoded}", with: encoded)
            result = result.replacingOccurrences(of: "{TEXT:ENCODED}", with: encoded)
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(of: "{text:trimmed}", with: trimmed)

        let lineCount = text.components(separatedBy: .newlines).count
        result = result.replacingOccurrences(of: "{linecount}", with: String(lineCount))

        let charCount = text.count
        result = result.replacingOccurrences(of: "{charcount}", with: String(charCount))

        return result
    }
}

extension CustomAction {
    static let exampleSummarize = CustomAction(
        name: "Summarize with ChatGPT",
        actionType: .openApp,
        template: "Summarize this text: {text}",
        contentFilter: .text,
        systemImage: "sparkles"
    )

    static let exampleTranslate = CustomAction(
        name: "Translate to English",
        actionType: .openURL,
        template: "https://translate.google.com/?text={text:encoded}",
        contentFilter: .text,
        systemImage: "globe"
    )

    static let exampleSearch = CustomAction(
        name: "Search on Google",
        actionType: .openURL,
        template: "https://www.google.com/search?q={text:encoded}",
        contentFilter: .text,
        systemImage: "magnifyingglass"
    )
}
