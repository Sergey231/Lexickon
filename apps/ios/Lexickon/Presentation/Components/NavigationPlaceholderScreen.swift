import SwiftUI

struct NavigationPlaceholderScreen<Actions: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let systemImage: String
    let accessibilityIdentifier: String
    @ViewBuilder let actions: Actions

    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String,
        accessibilityIdentifier: String,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(accessibilityIdentifier)

            Text(subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                actions
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
