import SwiftUI

struct WhimsicalTitle: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 32) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.custom(FontRegistration.keshia, size: size))
            .foregroundStyle(.primary)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct WhimsicalSubtitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.custom(FontRegistration.keshia, size: 18))
            .tracking(0.3)
            .foregroundStyle(.secondary)
            .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 0.5)
    }
}
