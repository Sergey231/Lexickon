import SwiftUI

@main
@MainActor
struct LexickonApp: App {
    private let appCoordinator: AppCoordinator

    init() {
        ProductionAssembly.makeContainer()
        appCoordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
        }
    }
}