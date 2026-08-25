import SwiftUI

@MainActor
struct MainOnboardingView: View {
    @State private var viewModel: MainOnboardingViewModel

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        _viewModel = State(initialValue: MainOnboardingViewModel(navigate: navigate))
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
