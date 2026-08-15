import Observation
import SwiftUI

enum DatasetSetupStep: CoordinatorStep {
    case selection
    case installation
    case storageInfo
    case installationDetails
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
        case .completed:
            onStep(.datasetSetupCompleted)
        }
    }
}

@MainActor
struct DatasetSetupCoordinatorView: View {
    @Bindable var coordinator: DatasetSetupCoordinator

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
                NavigationPlaceholderScreen(
                    title: "navigation.dataset.storage.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "internaldrive",
                    accessibilityIdentifier: "datasetSetup.storage.title"
                ) {
                    Button("navigation.close") {
                        coordinator.sheet = nil
                    }
                }
            case .selection, .installation, .installationDetails, .completed:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .installationDetails:
                NavigationPlaceholderScreen(
                    title: "navigation.dataset.installation.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "arrow.down.circle",
                    accessibilityIdentifier: "datasetSetup.installationDetails.title"
                ) {
                    Button("navigation.close") {
                        coordinator.fullScreenCover = nil
                    }
                }
            case .selection, .installation, .storageInfo, .completed:
                EmptyView()
            }
        }
    }

    private var setupRoot: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "square.stack.3d.up",
            accessibilityIdentifier: "datasetSetup.placeholder"
        ) {
            Button("navigation.dataset.complete") {
                coordinator.navigate(to: .completed)
            }
            .accessibilityIdentifier("datasetSetup.complete")

            Button("navigation.dataset.selection") {
                coordinator.navigate(to: .selection)
            }
            .buttonStyle(.bordered)

            Button("navigation.dataset.storage") {
                coordinator.navigate(to: .storageInfo)
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func destination(for step: DatasetSetupStep) -> some View {
        switch step {
        case .selection:
            NavigationPlaceholderScreen(
                title: "navigation.dataset.selection.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "checklist",
                accessibilityIdentifier: "datasetSetup.selection.title"
            ) {
                Button("navigation.dataset.install") {
                    coordinator.navigate(to: .installation)
                }
            }
        case .installation:
            NavigationPlaceholderScreen(
                title: "navigation.dataset.installation.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "arrow.down.circle",
                accessibilityIdentifier: "datasetSetup.installation.title"
            ) {
                Button("navigation.dataset.complete") {
                    coordinator.navigate(to: .completed)
                }
            }
        case .storageInfo, .installationDetails, .completed:
            EmptyView()
        }
    }
}

