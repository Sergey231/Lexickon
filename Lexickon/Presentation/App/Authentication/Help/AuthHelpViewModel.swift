import Observation

@Observable
@MainActor
final class AuthHelpViewModel {
    @ObservationIgnored private let navigate: @MainActor (AuthStep) -> Void

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        self.navigate = navigate
    }

    func closeTapped() {
        navigate(.root)
    }
}
