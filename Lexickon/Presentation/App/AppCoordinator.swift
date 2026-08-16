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
    let featureFactories: AppFeatureFactories

    var body: some View {
        Group {
            switch coordinator.currentStep {
            case .authenticationRequired:
                AuthFlow(
                    factory: featureFactories.auth
                ) { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .datasetSetupRequired:
                DatasetSetupFlow(
                    factory: featureFactories.datasetSetup
                ) { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                }
            case .mainRequired:
                MainFlow(
                    factory: featureFactories.main
                ) { [weak coordinator] step in
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

    init(
        factory: AuthFeatureFactory,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        AuthCoordinatorView(coordinator: coordinator)
    }
}

@MainActor
private struct DatasetSetupFlow: View {
    @State private var coordinator: DatasetSetupCoordinator

    init(
        factory: DatasetSetupFeatureFactory,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        DatasetSetupCoordinatorView(coordinator: coordinator)
    }
}

@MainActor
private struct MainFlow: View {
    @State private var coordinator: MainCoordinator

    init(
        factory: MainFeatureFactory,
        onStep: @escaping @MainActor (AppStep) -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(onStep: onStep)
        )
    }

    var body: some View {
        MainCoordinatorView(coordinator: coordinator)
    }
}
