import SwiftUI

@main
@MainActor
struct LexickonApp: App {
    private let container: AppContainer
    private let coordinator: AppCoordinator

    init() {
        container = ProductionAssembly.makeContainer()
        coordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
    }
}
