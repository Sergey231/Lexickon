import Observation

@Observable
@MainActor
final class DatasetInstallationViewModel {
    @ObservationIgnored private let navigate: @MainActor (AppStep) -> Void

    init(navigate: @escaping @MainActor (AppStep) -> Void) {
        self.navigate = navigate
    }

    func completeTapped() {
        navigate(.main)
    }
}
