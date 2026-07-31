import SwiftUI

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
                coordinator.finish(with: .completed)
            }
            .accessibilityIdentifier("datasetSetup.complete")

            Button("navigation.dataset.selection") {
                coordinator.handle(.selection)
            }
            .buttonStyle(.bordered)

            Button("navigation.dataset.storage") {
                coordinator.handle(.storageInfo)
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
                    coordinator.handle(.installation)
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
                    coordinator.finish(with: .completed)
                }
            }
        case .storageInfo, .installationDetails:
            EmptyView()
        }
    }
}
