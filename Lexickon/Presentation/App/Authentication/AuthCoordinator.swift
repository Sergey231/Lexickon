import Observation
import SwiftUI

enum AuthStep: CoordinatorStep {
    case login
    case registration
    case registrationCompleted
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
        case .registrationCompleted:
            path = [.login]
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
    let useCases: UseCases

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
            case .login, .registration, .registrationCompleted, .privacy,
                 .authenticated:
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
            case .login, .registration, .registrationCompleted, .help,
                 .authenticated:
                EmptyView()
            }
        }
    }

    private var authenticationRoot: some View {
        AuthRootView(
            authenticationState: useCases.authenticationState,
            onLogin: {
                coordinator.navigate(to: .login)
            },
            onRegistration: {
                coordinator.navigate(to: .registration)
            },
            onAuthenticated: {
                coordinator.navigate(to: .authenticated)
            },
            onHelp: {
                coordinator.navigate(to: .help)
            }
        )
    }

    @ViewBuilder
    private func destination(for step: AuthStep) -> some View {
        switch step {
        case .login:
            LoginView(
                login: useCases.login,
                onAuthenticated: {
                    coordinator.navigate(to: .authenticated)
                },
                onRegistration: {
                    coordinator.navigate(to: .registration)
                }
            )
        case .registration:
            RegistrationView(
                register: useCases.register,
                onRegistered: {
                    coordinator.navigate(to: .registrationCompleted)
                }
            )
        case .registrationCompleted, .help, .privacy, .authenticated:
            EmptyView()
        }
    }
}
