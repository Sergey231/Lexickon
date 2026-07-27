import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("placeholder.title")
                .font(.title.bold())
                .accessibilityIdentifier("placeholder.title")

            Text("placeholder.subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("placeholder.subtitle")
        }
        .padding(24)
    }
}

#Preview {
    PlaceholderView()
}
