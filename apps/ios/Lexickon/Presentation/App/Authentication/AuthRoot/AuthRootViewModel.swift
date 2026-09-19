import Observation

@Observable
@MainActor
final class AuthRootViewModel {
    @ObservationIgnored private let navigate: @MainActor (AuthStep) -> Void

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        self.navigate = navigate
    }

    func loginTapped() {
        navigate(.login)
    }

    func registrationTapped() {
        navigate(.registration)
    }

    func helpTapped() {
        navigate(.help)
    }
}
