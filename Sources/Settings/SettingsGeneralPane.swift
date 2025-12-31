import AppKit
import SwiftUI

@MainActor
struct SettingsGeneralPane: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSection(contentSpacing: 12) {
                    Text("System")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    PreferenceToggleRow(
                        title: "Start at Login",
                        subtitle: "Automatically opens CopyCopy when you start your Mac.",
                        binding: $settings.launchAtLogin)
                }

                Divider()

                SettingsSection(contentSpacing: 12) {
                    Text("Behavior")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    PreferenceToggleRow(
                        title: "Open popover on double ⌘C",
                        subtitle: "Shows the action menu when you press ⌘C twice quickly.",
                        binding: $settings.openPopoverOnDoubleCopy)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Double-copy threshold: \(Int(settings.doubleCopyThresholdMs))ms")
                            .font(.body)
                        Slider(value: $settings.doubleCopyThresholdMs, in: 150...500, step: 10)
                        Text("Time window to detect double ⌘C. Lower = faster, higher = more forgiving.")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }

                Divider()

                SettingsSection(contentSpacing: 12) {
                    HStack {
                        Spacer()
                        Button("Quit CopyCopy") { NSApp.terminate(nil) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}
