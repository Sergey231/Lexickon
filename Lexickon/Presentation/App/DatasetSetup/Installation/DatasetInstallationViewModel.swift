import Observation

@Observable
@MainActor
final class DatasetInstallationViewModel {
    @ObservationIgnored private let navigate: @MainActor (DatasetSetupStep) -> Void

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        self.navigate = navigate
    }

    func completeTapped() {
        navigate(.main)
    }
}
