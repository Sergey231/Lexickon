import SwiftUI

@MainActor
struct MainSearchView: View {
    @State private var viewModel: MainSearchViewModel

    init(
        logout: LogoutUseCase,
        navigate: @escaping @MainActor (MainStep) -> Void
    ) {
        _viewModel = State(
            initialValue: MainSearchViewModel(logout: logout, navigate: navigate)
        )
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "character.book.closed",
            accessibilityIdentifier: "main.placeholder"
        ) {
            Button("navigation.main.frequency") {
                viewModel.frequencyTapped()
            }

            Button("navigation.main.logout") {
                Task {
                    await viewModel.logoutTapped()
                }
            }
            .accessibilityIdentifier("main.logout")
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoggingOut)

            Button("navigation.main.sessionExpired") {
                viewModel.sessionExpiredTapped()
            }
            .accessibilityIdentifier("main.sessionExpired")
            .buttonStyle(.bordered)
        }
    }
}
