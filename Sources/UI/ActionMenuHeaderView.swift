import AppKit
import SwiftUI

struct ActionMenuHeaderView: View {
    let summary: String
    let appName: String?
    let appIcon: NSImage?
    let kindLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("CopyCopy")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                if let kindLabel {
                    Text(kindLabel.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(summary)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if let appName, !appName.isEmpty {
                HStack(spacing: 6) {
                    if let appIcon {
                        Image(nsImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    Text("From \(appName)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
