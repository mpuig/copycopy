import Cocoa

final class ClipboardClassifier {
    func snapshot(from pasteboard: NSPasteboard, changeCount: Int) -> ClipboardSnapshot {
        if let fileURLs = readFileURLs(from: pasteboard), !fileURLs.isEmpty {
            let exts = Set(fileURLs.map { $0.pathExtension.lowercased() }.filter { !$0.isEmpty })
            let extSummary = exts.isEmpty ? "" : " (\(exts.sorted().joined(separator: ", ")))"
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .fileURLs,
                summary: "\(fileURLs.count) file(s)\(extSummary)",
                fileURLs: fileURLs
            )
        }

        if let url = readNonFileURL(from: pasteboard) {
            let host = url.host.map { " — \($0)" } ?? ""
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .url,
                summary: "URL\(host)",
                url: url
            )
        }

        if let image = NSImage(pasteboard: pasteboard), image.isValid {
            let size = "\(Int(image.size.width))×\(Int(image.size.height))"
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .image,
                summary: "Image \(size)"
            )
        }

        if pasteboard.data(forType: .rtf) != nil {
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .richText,
                summary: "Rich text (RTF)",
                richTextType: .rtf
            )
        }

        if pasteboard.data(forType: .html) != nil {
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .richText,
                summary: "Rich text (HTML)",
                richTextType: .html
            )
        }

        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let short = trimmed.count > 140 ? String(trimmed.prefix(140)) + "…" : trimmed
            return ClipboardSnapshot(
                changeCount: changeCount,
                kind: .plainText,
                summary: "Text (\(trimmed.count) chars): \(short)",
                plainText: trimmed
            )
        }

        let types = pasteboard.types?.map(\.rawValue).sorted() ?? []
        let typeSummary = types.isEmpty ? "Unknown content" : "Unknown types: \(types.prefix(5).joined(separator: ", "))"
        return ClipboardSnapshot(changeCount: changeCount, kind: .unknown, summary: typeSummary)
    }

    private func readFileURLs(from pasteboard: NSPasteboard) -> [URL]? {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]
        return pasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL]
    }

    private func readNonFileURL(from pasteboard: NSPasteboard) -> URL? {
        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: false
        ]
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL] else {
            return nil
        }
        return urls.first(where: { $0.scheme?.lowercased() != "file" })
    }
}

