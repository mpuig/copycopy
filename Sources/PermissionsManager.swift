import Cocoa
import ApplicationServices

final class PermissionsManager {
    func hasAccessibilityPermission(promptIfNeeded: Bool) -> Bool {
        let options: NSDictionary? = promptIfNeeded
            ? [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
            : nil
        return AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }

    func openInputMonitoringSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") else { return }
        NSWorkspace.shared.open(url)
    }
}
