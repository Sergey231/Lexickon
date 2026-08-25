import Observation

@Observable
@MainActor
final class MainProfileViewModel {
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        self.navigate = navigate
    }

    func settingsTapped() {
        navigate(.settings)
    }

    func aboutTapped() {
        navigate(.about)
    }
}
