import Observation
import SwiftUI
import FactoryKit

enum AuthStep: CoordinatorStep {
    case root
    case login
    case registration
    case help
    case privacy
    case datasetSetup
}

@Observable
@MainActor
final class AuthCoordinator: Coordinator {
    var path: [AuthStep] = []
    var sheet: AuthStep?
    var fullScreenCover: AuthStep?
    private let onDatasetSetupRequested: @MainActor () -> Void

    init(onDatasetSetupRequested: @escaping @MainActor () -> Void) {
        self.onDatasetSetupRequested = onDatasetSetupRequested
    }

    func navigate(to step: AuthStep) {
        switch step {
        case .root:
            path = []
            sheet = nil
            fullScreenCover = nil
        case .login:
            path = [.login]
        case .registration:
            path.pushUnique(step)
        case .help:
            sheet = .help
        case .privacy:
            fullScreenCover = .privacy
        case .datasetSetup:
            onDatasetSetupRequested()
        }
    }
}

@MainActor
struct AuthCoordinatorView: View {
    @State private var coordinator: AuthCoordinator
    @Injected(\.loginUseCase) private var loginUseCase
    @Injected(\.registerUseCase) private var registerUseCase

    init(onDatasetSetupRequested: @escaping @MainActor () -> Void) {
        _coordinator = State(
            initialValue: AuthCoordinator(
                onDatasetSetupRequested: onDatasetSetupRequested
            )
        )
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
            case .root, .login, .registration, .privacy, .datasetSetup:
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
            case .root, .login, .registration, .help, .datasetSetup:
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
                    loginUseCase: loginUseCase,
                    navigate: { step in
                        coordinator.navigate(to: step)
                    }
                )
            )
        case .registration:
            RegistrationView(
                viewModel: RegistrationViewModel(
                    registerUseCase: registerUseCase,
                    navigate: { step in
                        coordinator.navigate(to: step)
                    }
                )
            )
        case .root, .help, .privacy, .datasetSetup:
            EmptyView()
        }
    }
}