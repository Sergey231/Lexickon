import SwiftUI

@MainActor
struct AuthPrivacyView: View {
    @State private var viewModel: AuthPrivacyViewModel

    init(viewModel: AuthPrivacyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.auth.privacy.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "hand.raised",
            accessibilityIdentifier: "auth.privacy.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
