import SwiftUI

@MainActor
struct MainProfileView: View {
    @State private var viewModel: MainProfileViewModel

    init(viewModel: MainProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
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
