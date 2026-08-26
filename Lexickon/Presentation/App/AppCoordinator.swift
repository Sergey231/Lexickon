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
                LaunchView(
                    viewModel: LaunchViewModel(
                        resolveLaunchDestinationUseCase: useCases.resolveLaunchDestinationUseCase,
                        navigate: { [weak coordinator] step in
                            coordinator?.navigate(to: step)
                        }
                    )
                )
            case .authenticationRequired:
                AuthCoordinatorView(onStep: { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                })
            case .datasetSetupRequired:
                DatasetSetupCoordinatorView(onStep: { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                })
            case .mainRequired:
                MainCoordinatorView(onStep: { [weak coordinator] step in
                    coordinator?.navigate(to: step)
                })
            case .launchCompleted, .authenticated, .datasetSetupCompleted,
                 .logout, .sessionExpired:
                EmptyView()
            }
        }
        .id(coordinator.currentStep)
    }
}
