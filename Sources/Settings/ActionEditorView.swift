import AppKit
import SwiftUI

@MainActor
struct ActionEditorView: View {
    @State private var action: CustomAction
    @State private var templateHeight: CGFloat = 120
    let isNew: Bool
    let onSave: (CustomAction) -> Void
    let onCancel: () -> Void

    init(action: CustomAction, isNew: Bool, onSave: @escaping (CustomAction) -> Void, onCancel: @escaping () -> Void) {
        self._action = State(initialValue: action)
        self.isNew = isNew
        self.onSave = onSave
        self.onCancel = onCancel
    }

    private var isValid: Bool {
        !action.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !action.template.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            formContent
            Divider()
            footer
        }
        .frame(width: 700, height: 780)
    }

    private var header: some View {
        HStack {
            Text(isNew ? "New Action" : "Edit Action")
                .font(.headline)
            Spacer()
        }
        .padding()
    }

    private var formContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                nameSection
                typeSection
                templateSection
                filterSection
                iconSection
                enabledSection
            }
            .padding()
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.subheadline.weight(.medium))
            TextField("Action name", text: $action.name)
                .textFieldStyle(.roundedBorder)
            Text("The name shown in the menu.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Action Type")
                .font(.subheadline.weight(.medium))
            Picker("Type", selection: $action.actionType) {
                ForEach(ActionType.allCases) { type in
                    Label(type.displayName, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text(actionTypeDescription)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var actionTypeDescription: String {
        switch action.actionType {
        case .openURL:
            return "Opens a URL in your default browser."
        case .shellCommand:
            return "Runs a shell command in the background."
        case .openApp:
            return "Opens an app and pastes the text."
        }
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(templateLabel)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Button {
                    if let url = URL(string: "https://github.com/anthropics/claude-code/wiki/CopyCopy-Action-Templates") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("View Examples", systemImage: "arrow.up.right.square")
                        .font(.caption)
                }
                .buttonStyle(.link)
            }

            if action.actionType == .openApp {
                appPicker
            }

            TextEditor(text: $action.template)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 140, maxHeight: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            examplesSection

            VStack(alignment: .leading, spacing: 4) {
                Text("Available variables:")
                    .font(.caption.weight(.medium))
                variablesHelp
            }
            .foregroundStyle(.tertiary)
        }
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick examples:")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                exampleButton("Google Search", template: "https://www.google.com/search?q={text:encoded}")
                exampleButton("Translate", template: "https://translate.google.com/?text={text:encoded}")
                exampleButton("ChatGPT Prompt", template: "Summarize this: {text}")
            }
        }
    }

    private func exampleButton(_ title: String, template: String) -> some View {
        Button {
            action.template = template
            if template.hasPrefix("http") {
                action.actionType = .openURL
            } else {
                action.actionType = .openApp
            }
        } label: {
            Text(title)
                .font(.caption)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    private var templateLabel: String {
        switch action.actionType {
        case .openURL: return "URL Template"
        case .shellCommand: return "Command"
        case .openApp: return "Text to Paste"
        }
    }

    @ViewBuilder
    private var appPicker: some View {
        HStack {
            Text("App:")
                .font(.subheadline)
            Picker("App", selection: appBinding) {
                Text("ChatGPT").tag("ChatGPT")
                Text("Claude").tag("Claude")
                Text("Other (specify in template)").tag("Other")
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private var appBinding: Binding<String> {
        Binding(
            get: {
                if action.template.lowercased().contains("chatgpt") || action.template.isEmpty {
                    return "ChatGPT"
                } else if action.template.lowercased().contains("claude") {
                    return "Claude"
                }
                return "Other"
            },
            set: { _ in }
        )
    }

    private var variablesHelp: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("{text} - The copied text")
            Text("{text:encoded} - URL-encoded text")
            Text("{text:trimmed} - Trimmed whitespace")
            Text("{charcount} - Character count")
            Text("{linecount} - Line count")
        }
        .font(.caption)
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Show for Content Type")
                .font(.subheadline.weight(.medium))
            Picker("Filter", selection: $action.contentFilter) {
                ForEach(ContentTypeFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            Text("Only show this action when the clipboard contains this type of content.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Icon")
                .font(.subheadline.weight(.medium))
            HStack(spacing: 12) {
                Image(systemName: action.systemImage)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(.quaternary)
                    .cornerRadius(6)

                TextField("SF Symbol name", text: $action.systemImage)
                    .textFieldStyle(.roundedBorder)
            }
            Text("Enter an SF Symbol name (e.g., star, sparkles, globe).")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var enabledSection: some View {
        Toggle("Enabled", isOn: $action.isEnabled)
            .toggleStyle(.checkbox)
    }

    private var footer: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .keyboardShortcut(.escape)

            Spacer()

            Button("Save") {
                onSave(action)
            }
            .keyboardShortcut(.return)
            .disabled(!isValid)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
