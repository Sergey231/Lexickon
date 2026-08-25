import SwiftUI

@MainActor
struct MainAboutView: View {
    @State private var viewModel: MainAboutViewModel

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        _viewModel = State(initialValue: MainAboutViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.about.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "info.circle",
            accessibilityIdentifier: "main.about.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
