import Cocoa

final class SuggestionEngine {
    func suggestions(for context: ClipboardContext) -> [SuggestedAction] {
        let sourceContext = context.sourceAppContext

        switch context.snapshot.kind {
        case .url:
            guard let url = context.snapshot.url else { return [] }
            return suggestionsForURL(url, sourceContext: sourceContext)

        case .fileURLs:
            let urls = context.snapshot.fileURLs ?? []
            return suggestionsForFileURLs(urls, sourceContext: sourceContext)

        case .image:
            return suggestionsForImage()

        case .plainText:
            let text = context.snapshot.plainText ?? ""
            return suggestionsForText(text, sourceContext: sourceContext)

        case .richText, .unknown:
            return [
                SuggestedAction(
                    title: "Show pasteboard types",
                    subtitle: nil,
                    systemImage: "doc.text.magnifyingglass"
                ) {
                    // No-op placeholder; details shown in UI.
                }
            ]
        }
    }

    private func suggestionsForURL(_ url: URL, sourceContext: SourceAppContext) -> [SuggestedAction] {
        var results: [SuggestedAction] = []

        results.append(
            SuggestedAction(
                title: "Open URL",
                subtitle: url.absoluteString,
                systemImage: "link"
            ) {
                NSWorkspace.shared.open(url)
            }
        )

        if sourceContext == .browser {
            results.append(
                SuggestedAction(
                    title: "Open in Safari",
                    subtitle: nil,
                    systemImage: "safari"
                ) {
                    guard let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") else { return }
                    let config = NSWorkspace.OpenConfiguration()
                    NSWorkspace.shared.open([url], withApplicationAt: safariURL, configuration: config)
                }
            )
        }

        return results
    }

    private func suggestionsForFileURLs(_ urls: [URL], sourceContext: SourceAppContext) -> [SuggestedAction] {
        guard !urls.isEmpty else { return [] }

        var results: [SuggestedAction] = []

        if urls.count == 1, let url = urls.first {
            results.append(SuggestedAction(title: "Open file", subtitle: url.lastPathComponent, systemImage: "doc") {
                NSWorkspace.shared.open(url)
            })
            results.append(SuggestedAction(title: "Reveal in Finder", subtitle: nil, systemImage: "folder") {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            })

            if sourceContext == .ide || sourceContext == .terminal {
                results.append(SuggestedAction(title: "Copy path", subtitle: url.path, systemImage: "doc.on.clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.path, forType: .string)
                })
            }
        } else {
            results.append(SuggestedAction(title: "Reveal in Finder", subtitle: "\(urls.count) items", systemImage: "folder") {
                NSWorkspace.shared.activateFileViewerSelecting(urls)
            })
        }

        return results
    }

    private func suggestionsForImage() -> [SuggestedAction] {
        [
            SuggestedAction(
                title: "Save Image…",
                subtitle: "Exports PNG without altering clipboard",
                systemImage: "square.and.arrow.down"
            ) {
                guard let image = NSImage(pasteboard: .general) else { return }
                saveImageAsPNG(image)
            }
        ]
    }

    private func suggestionsForText(_ text: String, sourceContext: SourceAppContext) -> [SuggestedAction] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var results: [SuggestedAction] = []

        if let url = URL(string: trimmed), url.scheme != nil {
            results.append(
                SuggestedAction(title: "Open as URL", subtitle: trimmed, systemImage: "link") {
                    NSWorkspace.shared.open(url)
                }
            )
        }

        if let dictURL = URL(string: "dict://\(trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") {
            results.append(
                SuggestedAction(title: "Look up in Dictionary", subtitle: nil, systemImage: "book") {
                    NSWorkspace.shared.open(dictURL)
                }
            )
        }

        if let searchURL = URL(string: "https://duckduckgo.com/?q=\(trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            results.append(
                SuggestedAction(title: "Search the web", subtitle: nil, systemImage: "magnifyingglass") {
                    NSWorkspace.shared.open(searchURL)
                }
            )
        }

        let prompt = "Summarize this text: \(trimmed)"
        results.append(
            SuggestedAction(title: "Summarize with ChatGPT", subtitle: nil, systemImage: "sparkles") {
                openInChatGPT(prompt: prompt)
            }
        )

        if sourceContext == .ide || sourceContext == .terminal {
            results.append(
                SuggestedAction(
                    title: "Open as temporary file",
                    subtitle: "Writes to a temp .txt",
                    systemImage: "doc.badge.plus"
                ) {
                    openTextAsTempFile(trimmed)
                }
            )

            if sourceContext == .terminal {
                results.append(
                    SuggestedAction(
                        title: "Strip ANSI codes",
                        subtitle: "Remove terminal color codes",
                        systemImage: "textformat"
                    ) {
                        let stripped = stripANSICodes(from: trimmed)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(stripped, forType: .string)
                    }
                )
            }
        }

        return results
    }
}

private func saveImageAsPNG(_ image: NSImage) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.png]
    savePanel.nameFieldStringValue = "Clipboard.png"

    savePanel.begin { response in
        guard response == .OK, let url = savePanel.url else { return }
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return }
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

private func openTextAsTempFile(_ text: String) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("CopyCopy", isDirectory: true)
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

    let fileURL = dir.appendingPathComponent("Clipboard-\(Int(Date().timeIntervalSince1970)).txt")
    do {
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
        NSWorkspace.shared.open(fileURL)
    } catch {
        // Best-effort; silently ignore.
    }
}

private func stripANSICodes(from text: String) -> String {
    let pattern = "\\x1B\\[[0-9;]*[A-Za-z]"
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
    let range = NSRange(text.startIndex..., in: text)
    return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
}

private func openInChatGPT(prompt: String) {
    let chatGPTBundleID = "com.openai.chat"

    if NSWorkspace.shared.urlForApplication(withBundleIdentifier: chatGPTBundleID) != nil {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt, forType: .string)

        let script = """
        tell application "ChatGPT"
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
        }
    } else {
        if let encoded = prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let webURL = URL(string: "https://chat.openai.com/?q=\(encoded)") {
            NSWorkspace.shared.open(webURL)
        }
    }
}
