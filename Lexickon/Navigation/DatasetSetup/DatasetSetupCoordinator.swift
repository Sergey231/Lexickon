import Observation

@Observable
@MainActor
final class DatasetSetupCoordinator: Coordinator {
    var path: [DatasetSetupStep] = []
    var sheet: DatasetSetupSheet?
    var fullScreenCover: DatasetSetupFullScreenCover?

    private let onFinish: @MainActor (DatasetSetupCoordinatorResult) -> Void

    init(onFinish: @escaping @MainActor (DatasetSetupCoordinatorResult) -> Void) {
        self.onFinish = onFinish
    }

    func handle(_ step: DatasetSetupStep) {
        switch step {
        case .selection, .installation:
            path.pushUnique(step)
        case .storageInfo:
            sheet = .storageInfo
        case .installationDetails:
            fullScreenCover = .installationDetails
        }
    }

    func finish(with result: DatasetSetupCoordinatorResult) {
        onFinish(result)
    }
}
