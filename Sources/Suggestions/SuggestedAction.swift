import Foundation

struct SuggestedAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let systemImage: String
    let perform: () -> Void
}

