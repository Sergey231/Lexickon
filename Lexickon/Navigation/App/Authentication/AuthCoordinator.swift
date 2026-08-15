import Observation
import SwiftUI

enum AuthStep: CoordinatorStep {
    case login
    case registration
    case help
    case privacy
    case authenticated
}

@Observable
@MainActor
final class AuthCoordinator: Coordinator {
    var path: [AuthStep] = []
    var sheet: AuthStep?
    var fullScreenCover: AuthStep?

    private let onStep: @MainActor (AppStep) -> Void

    init(onStep: @escaping @MainActor (AppStep) -> Void) {
        self.onStep = onStep
    }

    func navigate(to step: AuthStep) {
        switch step {
        case .login, .registration:
            path.pushUnique(step)
        case .help:
            sheet = .help
        case .privacy:
            fullScreenCover = .privacy
        case .authenticated:
            onStep(.authenticated)
        }
    }
}

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
            case .login, .registration, .privacy, .authenticated:
                EmptyView()
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
            case .login, .registration, .help, .authenticated:
                EmptyView()
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
                coordinator.navigate(to: .authenticated)
            }
            .accessibilityIdentifier("auth.complete")

            Button("navigation.auth.login") {
                coordinator.navigate(to: .login)
            }
            .buttonStyle(.bordered)

            Button("navigation.auth.help") {
                coordinator.navigate(to: .help)
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
                    coordinator.navigate(to: .authenticated)
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
                    coordinator.navigate(to: .authenticated)
                }
            }
        case .help, .privacy, .authenticated:
            EmptyView()
        }
    }
}

