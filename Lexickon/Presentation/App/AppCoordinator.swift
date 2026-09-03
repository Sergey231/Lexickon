import Observation
import SwiftUI

enum AppStep: CoordinatorStep {
    case launch
    case authentication
    case datasetSetup
    case main
}

@Observable
@MainActor
final class AppCoordinator: Coordinator {
    private(set) var currentStep: AppStep

    init(initialStep: AppStep = .launch) {
        currentStep = initialStep
    }

    func navigate(to step: AppStep) {
        currentStep = step
    }
}

@MainActor
struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator
    @Environment(\.useCases) private var useCases

    var body: some View {
        Group {
            switch coordinator.currentStep {
            case .launch:
                LaunchView(
                    viewModel: LaunchViewModel(
                        resolveLaunchDestinationUseCase: useCases.resolveLaunchDestinationUseCase,
                        navigate: { [weak coordinator] step in
                            coordinator?.navigate(to: step)
                        }
                    )
                )
            case .authentication:
                AuthCoordinatorView(onDatasetSetupRequested: { [weak coordinator] in
                    coordinator?.navigate(to: .datasetSetup)
                })
            case .datasetSetup:
                DatasetSetupCoordinatorView(onMainRequested: { [weak coordinator] in
                    coordinator?.navigate(to: .main)
                })
            case .main:
                MainCoordinatorView(onAuthenticationRequested: { [weak coordinator] in
                    coordinator?.navigate(to: .authentication)
                })
            }
        }
        .id(coordinator.currentStep)
    }
}
