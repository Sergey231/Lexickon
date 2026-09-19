import SwiftUI

@MainActor
struct MainOnboardingView: View {
    @State private var viewModel: MainOnboardingViewModel

    init(viewModel: MainOnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.onboarding.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "sparkles",
            accessibilityIdentifier: "main.onboarding.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
