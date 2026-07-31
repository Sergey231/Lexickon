import Observation

@Observable
@MainActor
final class AuthCoordinator: Coordinator {
    var path: [AuthStep] = []
    var sheet: AuthSheet?
    var fullScreenCover: AuthFullScreenCover?

    private let onFinish: @MainActor (AuthCoordinatorResult) -> Void

    init(onFinish: @escaping @MainActor (AuthCoordinatorResult) -> Void) {
        self.onFinish = onFinish
    }

    func handle(_ step: AuthStep) {
        switch step {
        case .login, .registration:
            path.pushUnique(step)
        case .help:
            sheet = .help
        case .privacy:
            fullScreenCover = .privacy
        }
    }

    func finish(with result: AuthCoordinatorResult) {
        onFinish(result)
    }
}
