import Cocoa

@MainActor
enum AboutPresenter {
    static func showAbout() {
        NSApp.activate(ignoringOtherApps: true)

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let versionString = build.isEmpty ? version : "\(version) (\(build))"

        let credits = NSMutableAttributedString(string: "CopyCopy — local-only clipboard helper\n")
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "CopyCopyHomepageURL") as? String,
           let url = URL(string: urlString),
           !urlString.isEmpty
        {
            credits.append(separator)
            credits.append(makeLink("Homepage", url: url))
        }

        let options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: "CopyCopy",
            .applicationVersion: versionString,
            .version: versionString,
            .credits: credits,
            .applicationIcon: (NSApplication.shared.applicationIconImage ?? NSImage()) as Any,
        ]

        NSApplication.shared.orderFrontStandardAboutPanel(options: options)
    }

    private static func makeLink(_ title: String, url: URL) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .link: url as Any,
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }

    private static var separator: NSAttributedString {
        NSAttributedString(string: " · ", attributes: [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
        ])
    }
}
