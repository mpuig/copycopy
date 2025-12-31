import Foundation
import ServiceManagement
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLogin()
        }
    }

    @Published var openPopoverOnDoubleCopy: Bool {
        didSet {
            UserDefaults.standard.set(openPopoverOnDoubleCopy, forKey: "openPopoverOnDoubleCopy")
        }
    }

    @Published var debugMenuEnabled: Bool {
        didSet {
            UserDefaults.standard.set(debugMenuEnabled, forKey: "debugMenuEnabled")
        }
    }

    @Published var doubleCopyThresholdMs: Double {
        didSet {
            UserDefaults.standard.set(doubleCopyThresholdMs, forKey: "doubleCopyThresholdMs")
        }
    }

    init() {
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        self.openPopoverOnDoubleCopy = UserDefaults.standard.object(forKey: "openPopoverOnDoubleCopy") as? Bool ?? true
        self.debugMenuEnabled = UserDefaults.standard.bool(forKey: "debugMenuEnabled")

        let stored = UserDefaults.standard.double(forKey: "doubleCopyThresholdMs")
        self.doubleCopyThresholdMs = stored > 0 ? stored : 280

        syncLaunchAtLoginState()
    }

    private func syncLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            let currentState = SMAppService.mainApp.status == .enabled
            if launchAtLogin != currentState {
                launchAtLogin = currentState
            }
        }
    }

    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("[AppSettings] Failed to update launch at login: \(error)")
            }
        }
    }
}
