import Observation
import SwiftUI

enum AppStep: CoordinatorStep {
    case launchRequired
    case launchCompleted(LaunchDestination)
    case authenticationRequired
    case authenticated
    case datasetSetupRequired
    case datasetSetupCompleted
    case mainRequired
    case logout
    case sessionExpired
}

@Observable
@MainActor
final class AppCoordinator: Coordinator {
    private(set) var currentStep: AppStep

    init(initialStep: AppStep = .launchRequired) {
        currentStep = .launchRequired
        navigate(to: initialStep)
    }

    func navigate(to step: AppStep) {
        currentStep = switch step {
        case .launchRequired:
            .launchRequired
        case .launchCompleted(.login):
            .authenticationRequired
        case .launchCompleted(.main):
            .mainRequired
        case .authenticationRequired, .logout, .sessionExpired:
            .authenticationRequired
        case .authenticated, .datasetSetupRequired:
            .datasetSetupRequired
        case .datasetSetupCompleted, .mainRequired:
            .mainRequired
        }
    }
}

@MainActor
struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator
    @Environment(\.useCases) private var useCases

    var body: some View {
        Group {
            switch coordinator.currentStep {
            case .launchRequired:
                LaunchFlow(useCases: useCases) { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .authenticationRequired:
                AuthFlow(useCases: useCases) { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .datasetSetupRequired:
                DatasetSetupFlow { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .mainRequired:
                MainFlow(useCases: useCases) { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .launchCompleted, .authenticated, .datasetSetupCompleted,
                 .logout, .sessionExpired:
                EmptyView()
            }
        }
        .id(coordinator.currentStep)
    }
}

@MainActor
private struct LaunchFlow: View {
    private let useCases: UseCases
    private let onStep: @MainActor (AppStep) -> Void

    init(
        useCases: UseCases,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        self.useCases = useCases
        self.onStep = onStep
    }

    var body: some View {
        LaunchView(resolveDestination: useCases.resolveLaunchDestination) { step in
            onStep(step)
        }
    }
}

@MainActor
private struct AuthFlow: View {
    @State private var coordinator: AuthCoordinator
    private let useCases: UseCases

    init(
        useCases: UseCases,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        self.useCases = useCases
        _coordinator = State(
            initialValue: AuthCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        AuthCoordinatorView(
            coordinator: coordinator,
            useCases: useCases
        )
    }
}

@MainActor
private struct DatasetSetupFlow: View {
    @State private var coordinator: DatasetSetupCoordinator

    init(
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        _coordinator = State(
            initialValue: DatasetSetupCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        DatasetSetupCoordinatorView(coordinator: coordinator)
    }
}

@MainActor
private struct MainFlow: View {
    @State private var coordinator: MainCoordinator
    private let useCases: UseCases

    init(
        useCases: UseCases,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        self.useCases = useCases
        _coordinator = State(
            initialValue: MainCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        MainCoordinatorView(
            coordinator: coordinator,
            logout: useCases.logout
        )
    }
}
