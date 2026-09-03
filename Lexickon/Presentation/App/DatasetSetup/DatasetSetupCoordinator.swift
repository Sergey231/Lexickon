import Observation
import SwiftUI

enum DatasetSetupStep: CoordinatorStep {
    case root
    case selection
    case installation
    case storageInfo
    case installationDetails
    case main
}

@Observable
@MainActor
final class DatasetSetupCoordinator: Coordinator {
    var path: [DatasetSetupStep] = []
    var sheet: DatasetSetupStep?
    var fullScreenCover: DatasetSetupStep?
    private let onMainRequested: @MainActor () -> Void

    init(onMainRequested: @escaping @MainActor () -> Void) {
        self.onMainRequested = onMainRequested
    }

    func navigate(to step: DatasetSetupStep) {
        switch step {
        case .root:
            path = []
            sheet = nil
            fullScreenCover = nil
        case .selection, .installation:
            path.pushUnique(step)
        case .storageInfo:
            sheet = .storageInfo
        case .installationDetails:
            fullScreenCover = .installationDetails
        case .main:
            onMainRequested()
        }
    }
}

@MainActor
struct DatasetSetupCoordinatorView: View {
    @State private var coordinator: DatasetSetupCoordinator

    init(onMainRequested: @escaping @MainActor () -> Void) {
        _coordinator = State(
            initialValue: DatasetSetupCoordinator(onMainRequested: onMainRequested)
        )
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
            case .root, .selection, .installation, .installationDetails, .main:
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
            case .root, .selection, .installation, .storageInfo, .main:
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
        case .root, .storageInfo, .installationDetails, .main:
            EmptyView()
        }
    }
}
