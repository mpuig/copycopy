import Cocoa
import SwiftUI
import Combine

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let model: AppModel
    private let contextMenu = NSMenu()
    private var cancellables = Set<AnyCancellable>()
    private var activeMenu: NSMenu?

    init(model: AppModel) {
        self.model = model
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: model.menuBarSymbolName, accessibilityDescription: "CopyCopy")
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        contextMenu.addItem(NSMenuItem(title: "Show", action: #selector(openActionMenu), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "About CopyCopy", action: #selector(showAbout), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Open Accessibility Settings…", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Open Input Monitoring…", action: #selector(openInputMonitoringSettings), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Re-check Permissions", action: #selector(recheckPermissions), keyEquivalent: ""))
        contextMenu.addItem(.separator())
        contextMenu.addItem(NSMenuItem(title: "Quit CopyCopy", action: #selector(quit), keyEquivalent: "q"))
        contextMenu.items.forEach { $0.target = self }

        model.$lastClipboardContext
            .combineLatest(model.$hasAccessibilityPermission)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.refreshStatusItemIcon()
            }
            .store(in: &cancellables)
    }

    @objc private func statusItemClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            DispatchQueue.main.async { [weak self] in
                self?.showContextMenu()
            }
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.openActionMenu()
        }
    }

    @objc func openActionMenu() {
        model.refreshSuggestions()
        NSApp.activate(ignoringOtherApps: true)
        showActionMenu()
    }

    @objc private func openAccessibilitySettings() {
        model.openAccessibilitySettings()
    }

    @objc private func openInputMonitoringSettings() {
        model.openInputMonitoringSettings()
    }

    @objc private func showAbout() {
        model.showAbout()
    }

    @objc private func recheckPermissions() {
        model.refreshPermissions(promptIfNeeded: false)
    }

    private func showContextMenu() {
        present(menu: contextMenu)
    }

    private func refreshStatusItemIcon() {
        statusItem.button?.image = NSImage(systemSymbolName: model.menuBarSymbolName, accessibilityDescription: "CopyCopy")
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func showActionMenu() {
        let menu = NSMenu()

        let width: CGFloat = 320
        let header = makeHeaderView(width: width)
        let headerItem = NSMenuItem()
        headerItem.view = header
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        menu.addItem(.separator())

        if !model.hasAccessibilityPermission {
            let item = NSMenuItem(title: "Enable Accessibility…", action: #selector(openAccessibilitySettings), keyEquivalent: "")
            item.target = self
            menu.addItem(item)
            let item2 = NSMenuItem(title: "Enable Input Monitoring…", action: #selector(openInputMonitoringSettings), keyEquivalent: "")
            item2.target = self
            menu.addItem(item2)
            let item3 = NSMenuItem(title: "Re-check Permissions", action: #selector(recheckPermissions), keyEquivalent: "")
            item3.target = self
            menu.addItem(item3)
            menu.addItem(.separator())
        }

        let actions = model.suggestedActions
        if actions.isEmpty {
            let none = NSMenuItem(title: "No actions", action: nil, keyEquivalent: "")
            none.isEnabled = false
            menu.addItem(none)
        } else {
            for action in actions {
                let item = NSMenuItem(title: action.title, action: #selector(runSuggestedAction(_:)), keyEquivalent: "")
                item.target = self
                item.toolTip = action.subtitle
                item.image = NSImage(systemSymbolName: action.systemImage, accessibilityDescription: action.title)
                item.representedObject = MenuAction(perform: action.perform)
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())
        let about = NSMenuItem(title: "About CopyCopy", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)
        let quitItem = NSMenuItem(title: "Quit CopyCopy", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        present(menu: menu)
    }

    private func makeHeaderView(width: CGFloat) -> NSView {
        let context = model.lastClipboardContext
        let summary = context?.snapshot.summary ?? "Copy something, then double ⌘C."
        let kind = context?.snapshot.kind.rawValue
        let appName = context?.copyEvent?.appName
        let appIcon = context?.copyEvent.flatMap { NSRunningApplication(processIdentifier: $0.pid)?.icon }

        let view = ActionMenuHeaderView(summary: summary, appName: appName, appIcon: appIcon, kindLabel: kind)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: 64)
        hosting.layoutSubtreeIfNeeded()
        let fitting = hosting.fittingSize
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: max(64, fitting.height))
        return hosting
    }

    @objc private func runSuggestedAction(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? MenuAction else { return }
        action.perform()
    }

    private func present(menu: NSMenu) {
        activeMenu = menu
        menu.delegate = self
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        if activeMenu === menu {
            activeMenu = nil
            statusItem.menu = nil
        }
    }
}

private final class MenuAction: NSObject {
    let perform: () -> Void

    init(perform: @escaping () -> Void) {
        self.perform = perform
    }
}
