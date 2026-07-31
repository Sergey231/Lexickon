import Observation

@Observable
@MainActor
final class MainCoordinator: Coordinator {
    var path: [MainStep] = []
    var sheet: MainSheet?
    var fullScreenCover: MainFullScreenCover?
    var selectedTab: MainTab = .search

    private let onFinish: @MainActor (MainCoordinatorResult) -> Void

    init(onFinish: @escaping @MainActor (MainCoordinatorResult) -> Void) {
        self.onFinish = onFinish
    }

    func handle(_ step: MainStep) {
        switch step {
        case .frequency, .profile, .settings:
            path.pushUnique(step)
        case .about:
            sheet = .about
        case .onboarding:
            fullScreenCover = .onboarding
        case let .selectTab(tab):
            selectedTab = tab
        }
    }

    func finish(with result: MainCoordinatorResult) {
        onFinish(result)
    }
}
