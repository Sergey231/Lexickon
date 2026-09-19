import Observation

@Observable
@MainActor
final class DatasetSetupRootViewModel {
    @ObservationIgnored private let navigate: @MainActor (DatasetSetupStep) -> Void

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        self.navigate = navigate
    }

    func completeTapped() {
        navigate(.main)
    }

    func selectionTapped() {
        navigate(.selection)
    }

    func storageTapped() {
        navigate(.storageInfo)
    }
}
