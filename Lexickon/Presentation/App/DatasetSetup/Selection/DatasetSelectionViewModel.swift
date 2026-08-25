import Observation

@Observable
@MainActor
final class DatasetSelectionViewModel {
    @ObservationIgnored private let navigate: @MainActor (DatasetSetupStep) -> Void

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        self.navigate = navigate
    }

    func installTapped() {
        navigate(.installation)
    }
}
