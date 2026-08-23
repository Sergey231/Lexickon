import Observation
import SwiftUI

enum AppStep: CoordinatorStep {
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

    init(initialStep: AppStep = .authenticationRequired) {
        currentStep = .authenticationRequired
        navigate(to: initialStep)
    }

    func navigate(to step: AppStep) {
        currentStep = switch step {
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
            case .authenticated, .datasetSetupCompleted, .logout, .sessionExpired:
                EmptyView()
            }
        }
        .id(coordinator.currentStep)
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
