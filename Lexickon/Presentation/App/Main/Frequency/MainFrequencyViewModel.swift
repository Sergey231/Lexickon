import Observation

@Observable
@MainActor
final class MainFrequencyViewModel {
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        self.navigate = navigate
    }

    func openFrequencyTapped() {
        navigate(.frequency)
    }
}
