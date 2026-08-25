import Observation

@Observable
@MainActor
final class DatasetStorageInfoViewModel {
    @ObservationIgnored private let navigate: @MainActor (DatasetSetupStep) -> Void

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        self.navigate = navigate
    }

    func closeTapped() {
        navigate(.storageInfoDismissed)
    }
}
