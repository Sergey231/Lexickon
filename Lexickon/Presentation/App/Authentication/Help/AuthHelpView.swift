import SwiftUI

@MainActor
struct AuthHelpView: View {
    @State private var viewModel: AuthHelpViewModel

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        _viewModel = State(initialValue: AuthHelpViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.auth.help.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "questionmark.circle",
            accessibilityIdentifier: "auth.help.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
