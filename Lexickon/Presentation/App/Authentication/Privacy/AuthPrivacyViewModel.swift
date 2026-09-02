import Observation

@Observable
@MainActor
final class AuthPrivacyViewModel {
    @ObservationIgnored private let navigate: @MainActor (AuthStep) -> Void

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        self.navigate = navigate
    }

    func closeTapped() {
        navigate(.root)
    }
}
