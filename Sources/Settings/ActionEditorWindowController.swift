import Cocoa
import SwiftUI

@MainActor
final class ActionEditorWindowController {
    static let shared = ActionEditorWindowController()
    private var window: NSWindow?

    private init() {}

    func show(
        action: CustomAction,
        isNew: Bool,
        onSave: @escaping (CustomAction) -> Void,
        onCancel: @escaping () -> Void
    ) {
        if let existingWindow = window {
            existingWindow.close()
        }

        let editorView = ActionEditorView(
            action: action,
            isNew: isNew,
            onSave: { [weak self] savedAction in
                onSave(savedAction)
                self?.window?.close()
                self?.window = nil
            },
            onCancel: { [weak self] in
                onCancel()
                self?.window?.close()
                self?.window = nil
            }
        )

        let hostingController = NSHostingController(rootView: editorView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = isNew ? "New Action" : "Edit Action"
        newWindow.styleMask = [.titled, .closable]
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating

        self.window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
    }
}
