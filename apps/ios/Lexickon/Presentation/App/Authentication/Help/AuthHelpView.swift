import SwiftUI

@MainActor
struct AuthHelpView: View {
    @State private var viewModel: AuthHelpViewModel

    init(viewModel: AuthHelpViewModel) {
        _viewModel = State(initialValue: viewModel)
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
