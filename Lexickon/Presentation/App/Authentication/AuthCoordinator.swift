import Observation
import SwiftUI

enum AuthStep: CoordinatorStep {
    case login
    case registration
    case registrationCompleted
    case help
    case privacy
    case helpDismissed
    case privacyDismissed
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
        case .helpDismissed:
            sheet = nil
        case .privacyDismissed:
            fullScreenCover = nil
        case .authenticated:
            onStep(.authenticated)
        }
    }
}

@MainActor
struct AuthCoordinatorView: View {
    @State private var coordinator: AuthCoordinator
    @Environment(\.useCases) private var useCases

    init(onStep: @escaping @MainActor (AppStep) -> Void) {
        _coordinator = State(initialValue: AuthCoordinator(onStep: onStep))
    }

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
                AuthHelpView(
                    viewModel: AuthHelpViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .login, .registration, .registrationCompleted, .privacy,
                 .helpDismissed, .privacyDismissed, .authenticated:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .privacy:
                AuthPrivacyView(
                    viewModel: AuthPrivacyViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .login, .registration, .registrationCompleted, .help,
                 .helpDismissed, .privacyDismissed, .authenticated:
                EmptyView()
            }
        }
    }

    private var authenticationRoot: some View {
        AuthRootView(
            viewModel: AuthRootViewModel { step in
                coordinator.navigate(to: step)
            }
        )
    }

    @ViewBuilder
    private func destination(for step: AuthStep) -> some View {
        switch step {
        case .login:
            LoginView(
                viewModel: LoginViewModel(
                    loginUseCase: useCases.loginUseCase,
                    navigate: { step in
                        coordinator.navigate(to: step)
                    }
                )
            )
        case .registration:
            RegistrationView(
                viewModel: RegistrationViewModel(
                    registerUseCase: useCases.registerUseCase,
                    navigate: { step in
                        coordinator.navigate(to: step)
                    }
                )
            )
        case .registrationCompleted, .help, .privacy, .helpDismissed,
             .privacyDismissed, .authenticated:
            EmptyView()
        }
    }
}
