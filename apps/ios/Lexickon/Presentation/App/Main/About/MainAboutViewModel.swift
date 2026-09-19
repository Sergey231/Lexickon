import Observation

@Observable
@MainActor
final class MainAboutViewModel {
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        self.navigate = navigate
    }

    func closeTapped() {
        navigate(.root)
    }
}
