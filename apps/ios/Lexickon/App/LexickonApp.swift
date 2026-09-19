import SwiftUI

@main
@MainActor
struct LexickonApp: App {
    private let appContainer: AppContainer
    private let appCoordinator: AppCoordinator

    init() {
        appContainer = ProductionAssembly.makeContainer()
        appCoordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
                .environment(\.useCases, appContainer.useCases)
        }
    }
}
