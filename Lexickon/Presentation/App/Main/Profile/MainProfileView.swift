import SwiftUI

@MainActor
struct MainProfileView: View {
    @State private var viewModel: MainProfileViewModel

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        _viewModel = State(initialValue: MainProfileViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.profile.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "person.crop.circle",
            accessibilityIdentifier: "main.profile.title"
        ) {
            Button("navigation.main.settings") {
                viewModel.settingsTapped()
            }

            Button("navigation.main.about") {
                viewModel.aboutTapped()
            }
            .buttonStyle(.bordered)
        }
    }
}
