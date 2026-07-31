import Observation

@Observable
@MainActor
final class AppCoordinator: Coordinator {
    private(set) var root: AppRoot
    private(set) var rootRevision = 0

    private(set) var authCoordinator: AuthCoordinator?
    private(set) var datasetSetupCoordinator: DatasetSetupCoordinator?
    private(set) var mainCoordinator: MainCoordinator?

    init(initialStep: AppStep = .showAuthentication) {
        root = .authentication
        handle(initialStep)
    }

    func handle(_ step: AppStep) {
        switch step {
        case .showAuthentication, .logout, .sessionExpired:
            replaceRoot(with: .authentication)
        case .showDatasetSetup:
            replaceRoot(with: .datasetSetup)
        case .showMain:
            replaceRoot(with: .main)
        }
    }

    func handle(_ result: AuthCoordinatorResult) {
        switch result {
        case .authenticated:
            handle(.showDatasetSetup)
        }
    }

    func handle(_ result: DatasetSetupCoordinatorResult) {
        switch result {
        case .completed:
            handle(.showMain)
        }
    }

    func handle(_ result: MainCoordinatorResult) {
        switch result {
        case .logout:
            handle(AppStep.logout)
        case .sessionExpired:
            handle(AppStep.sessionExpired)
        }
    }

    private func replaceRoot(with newRoot: AppRoot) {
        if root == newRoot, activeChildExists(for: newRoot) {
            return
        }

        releaseChildren()
        root = newRoot
        rootRevision += 1

        switch newRoot {
        case .authentication:
            authCoordinator = AuthCoordinator { [weak self] result in
                self?.handle(result)
            }
        case .datasetSetup:
            datasetSetupCoordinator = DatasetSetupCoordinator { [weak self] result in
                self?.handle(result)
            }
        case .main:
            mainCoordinator = MainCoordinator { [weak self] result in
                self?.handle(result)
            }
        }
    }

    private func activeChildExists(for root: AppRoot) -> Bool {
        switch root {
        case .authentication:
            authCoordinator != nil
        case .datasetSetup:
            datasetSetupCoordinator != nil
        case .main:
            mainCoordinator != nil
        }
    }

    private func releaseChildren() {
        authCoordinator = nil
        datasetSetupCoordinator = nil
        mainCoordinator = nil
    }
}
