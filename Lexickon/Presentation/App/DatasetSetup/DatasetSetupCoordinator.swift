import Observation
import SwiftUI

enum DatasetSetupStep: CoordinatorStep {
    case selection
    case installation
    case storageInfo
    case installationDetails
    case storageInfoDismissed
    case installationDetailsDismissed
    case completed
}

@Observable
@MainActor
final class DatasetSetupCoordinator: Coordinator {
    var path: [DatasetSetupStep] = []
    var sheet: DatasetSetupStep?
    var fullScreenCover: DatasetSetupStep?

    private let onStep: @MainActor (AppStep) -> Void

    init(onStep: @escaping @MainActor (AppStep) -> Void) {
        self.onStep = onStep
    }

    func navigate(to step: DatasetSetupStep) {
        switch step {
        case .selection, .installation:
            path.pushUnique(step)
        case .storageInfo:
            sheet = .storageInfo
        case .installationDetails:
            fullScreenCover = .installationDetails
        case .storageInfoDismissed:
            sheet = nil
        case .installationDetailsDismissed:
            fullScreenCover = nil
        case .completed:
            onStep(.datasetSetupCompleted)
        }
    }
}

@MainActor
struct DatasetSetupCoordinatorView: View {
    @State private var coordinator: DatasetSetupCoordinator

    init(onStep: @escaping @MainActor (AppStep) -> Void) {
        _coordinator = State(initialValue: DatasetSetupCoordinator(onStep: onStep))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            setupRoot
                .navigationDestination(for: DatasetSetupStep.self) { step in
                    destination(for: step)
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .storageInfo:
                DatasetStorageInfoView(
                    viewModel: DatasetStorageInfoViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .selection, .installation, .installationDetails,
                 .storageInfoDismissed, .installationDetailsDismissed,
                 .completed:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .installationDetails:
                DatasetInstallationDetailsView(
                    viewModel: DatasetInstallationDetailsViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .selection, .installation, .storageInfo,
                 .storageInfoDismissed, .installationDetailsDismissed,
                 .completed:
                EmptyView()
            }
        }
    }

    private var setupRoot: some View {
        DatasetSetupRootView(
            viewModel: DatasetSetupRootViewModel { step in
                coordinator.navigate(to: step)
            }
        )
    }

    @ViewBuilder
    private func destination(for step: DatasetSetupStep) -> some View {
        switch step {
        case .selection:
            DatasetSelectionView(
                viewModel: DatasetSelectionViewModel { step in
                    coordinator.navigate(to: step)
                }
            )
        case .installation:
            DatasetInstallationView(
                viewModel: DatasetInstallationViewModel { step in
                    coordinator.navigate(to: step)
                }
            )
        case .storageInfo, .installationDetails, .storageInfoDismissed,
             .installationDetailsDismissed, .completed:
            EmptyView()
        }
    }
}
