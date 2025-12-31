import Cocoa
import MenuBarExtraAccess
import QuartzCore
import SwiftUI

@main
@MainActor
struct CopyCopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model: AppModel
    @StateObject private var settings: AppSettings
    @StateObject private var actionsStore: CustomActionsStore
    @State private var isMenuPresented = false
    @State private var statusItem: NSStatusItem?

    init() {
        let settings = AppSettings()
        let actionsStore = CustomActionsStore()
        let model = AppModel(settings: settings, actionsStore: actionsStore)
        _settings = StateObject(wrappedValue: settings)
        _actionsStore = StateObject(wrappedValue: actionsStore)
        _model = StateObject(wrappedValue: model)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(model: model, settings: settings, actionsStore: actionsStore, updater: appDelegate.updaterController)
        } label: {
            StatusItemLabel(model: model)
        }
        .menuBarExtraAccess(isPresented: $isMenuPresented) { item in
            statusItem = item
        }
        .onChange(of: model.triggerPulseID) { _, _ in
            pulseStatusItem()
            if settings.openPopoverOnDoubleCopy {
                isMenuPresented = true
            }
        }

        Settings {
            SettingsView(settings: settings, model: model, actionsStore: actionsStore, updater: appDelegate.updaterController)
        }
    }

    private func pulseStatusItem() {
        guard let button = statusItem?.button else { return }
        button.wantsLayer = true
        if let layer = button.layer {
            let baseOpacity = layer.opacity
            let targetOpacity = max(0.25, baseOpacity * 0.4)
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = baseOpacity
            animation.toValue = targetOpacity
            animation.duration = 0.18
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.removeAnimation(forKey: "triggerPulse")
            layer.add(animation, forKey: "triggerPulse")
        }
    }
}

private struct StatusItemLabel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Label {
            Text("CopyCopy")
        } icon: {
            Image(systemName: model.menuBarSymbolName)
                .symbolRenderingMode(.hierarchical)
        }
        .foregroundStyle(model.hasAccessibilityPermission ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
        .opacity(model.hasAccessibilityPermission ? 1.0 : 0.45)
    }
}
