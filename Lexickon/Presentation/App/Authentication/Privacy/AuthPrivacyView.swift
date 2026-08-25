import SwiftUI

@MainActor
struct AuthPrivacyView: View {
    @State private var viewModel: AuthPrivacyViewModel

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        _viewModel = State(initialValue: AuthPrivacyViewModel(navigate: navigate))
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
