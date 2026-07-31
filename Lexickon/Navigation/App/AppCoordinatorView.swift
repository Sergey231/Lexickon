import SwiftUI

@MainActor
struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.root {
            case .authentication:
                if let child = coordinator.authCoordinator {
                    AuthCoordinatorView(coordinator: child)
                }
            case .datasetSetup:
                if let child = coordinator.datasetSetupCoordinator {
                    DatasetSetupCoordinatorView(coordinator: child)
                }
            case .main:
                if let child = coordinator.mainCoordinator {
                    MainCoordinatorView(coordinator: child)
                }
            }
        }
        .id(coordinator.rootRevision)
    }
}
