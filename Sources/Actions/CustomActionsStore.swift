import Cocoa
import Foundation

@MainActor
final class CustomActionsStore: ObservableObject {
    @Published var actions: [CustomAction] = []

    private let storageKey = "customActions"

    init() {
        loadActions()
    }

    func loadActions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            actions = []
            return
        }

        do {
            actions = try JSONDecoder().decode([CustomAction].self, from: data)
        } catch {
            print("[CustomActionsStore] Failed to decode actions: \(error)")
            actions = []
        }
    }

    func saveActions() {
        do {
            let data = try JSONEncoder().encode(actions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[CustomActionsStore] Failed to encode actions: \(error)")
        }
    }

    func addAction(_ action: CustomAction) {
        actions.append(action)
        saveActions()
    }

    func updateAction(_ action: CustomAction) {
        if let index = actions.firstIndex(where: { $0.id == action.id }) {
            actions[index] = action
            saveActions()
        }
    }

    func removeAction(_ action: CustomAction) {
        actions.removeAll { $0.id == action.id }
        saveActions()
    }

    func removeActions(at offsets: IndexSet) {
        actions.remove(atOffsets: offsets)
        saveActions()
    }

    func moveActions(from source: IndexSet, to destination: Int) {
        actions.move(fromOffsets: source, toOffset: destination)
        saveActions()
    }

    func enabledActions(for contentKind: ClipboardContentKind) -> [CustomAction] {
        actions.filter { $0.isEnabled && $0.contentFilter.matches(contentKind) }
    }

    func execute(_ action: CustomAction, with context: ClipboardContext) {
        let text = context.snapshot.plainText ?? context.snapshot.url?.absoluteString ?? ""
        let processedTemplate = action.processTemplate(with: text)

        switch action.actionType {
        case .openURL:
            executeOpenURL(processedTemplate)
        case .shellCommand:
            executeShellCommand(processedTemplate)
        case .openApp:
            executeOpenApp(action, processedText: processedTemplate)
        }
    }

    private func executeOpenURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("[CustomActionsStore] Invalid URL: \(urlString)")
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func executeShellCommand(_ command: String) {
        Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]

            do {
                try process.run()
            } catch {
                print("[CustomActionsStore] Failed to run command: \(error)")
            }
        }
    }

    private func executeOpenApp(_ action: CustomAction, processedText: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(processedText, forType: .string)

        let appName = extractAppName(from: action.template) ?? "ChatGPT"

        let script = """
        tell application "\(appName)"
            activate
        end tell
        delay 0.5
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error {
                print("[CustomActionsStore] AppleScript error: \(error)")
            }
        }
    }

    private func extractAppName(from template: String) -> String? {
        if template.lowercased().contains("chatgpt") {
            return "ChatGPT"
        }
        if template.lowercased().contains("claude") {
            return "Claude"
        }
        return nil
    }
}
