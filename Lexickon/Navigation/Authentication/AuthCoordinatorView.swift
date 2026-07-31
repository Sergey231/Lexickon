import SwiftUI

@MainActor
struct AuthCoordinatorView: View {
    @Bindable var coordinator: AuthCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            authenticationRoot
                .navigationDestination(for: AuthStep.self) { step in
                    destination(for: step)
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .help:
                NavigationPlaceholderScreen(
                    title: "navigation.auth.help.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "questionmark.circle",
                    accessibilityIdentifier: "auth.help.title"
                ) {
                    Button("navigation.close") {
                        coordinator.sheet = nil
                    }
                }
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .privacy:
                NavigationPlaceholderScreen(
                    title: "navigation.auth.privacy.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "hand.raised",
                    accessibilityIdentifier: "auth.privacy.title"
                ) {
                    Button("navigation.close") {
                        coordinator.fullScreenCover = nil
                    }
                }
            }
        }
    }

    private var authenticationRoot: some View {
        NavigationPlaceholderScreen(
            title: "navigation.auth.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "person.crop.circle.badge.key",
            accessibilityIdentifier: "auth.placeholder"
        ) {
            Button("navigation.auth.continue") {
                coordinator.finish(with: .authenticated)
            }
            .accessibilityIdentifier("auth.complete")

            Button("navigation.auth.login") {
                coordinator.handle(.login)
            }
            .buttonStyle(.bordered)

            Button("navigation.auth.help") {
                coordinator.handle(.help)
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func destination(for step: AuthStep) -> some View {
        switch step {
        case .login:
            NavigationPlaceholderScreen(
                title: "navigation.auth.login.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "key",
                accessibilityIdentifier: "auth.login.title"
            ) {
                Button("navigation.auth.continue") {
                    coordinator.finish(with: .authenticated)
                }
            }
        case .registration:
            NavigationPlaceholderScreen(
                title: "navigation.auth.registration.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "person.badge.plus",
                accessibilityIdentifier: "auth.registration.title"
            ) {
                Button("navigation.auth.continue") {
                    coordinator.finish(with: .authenticated)
                }
            }
        case .help, .privacy:
            EmptyView()
        }
    }
}
