import Observation

@Observable
@MainActor
final class MainSearchViewModel {
    private(set) var isLoggingOut = false
    private(set) var error: AppError?

    private let logout: LogoutUseCase
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void

    init(
        logout: LogoutUseCase,
        navigate: @escaping @MainActor (MainStep) -> Void
    ) {
        self.logout = logout
        self.navigate = navigate
    }

    func frequencyTapped() {
        navigate(.selectTab(.frequency))
    }

    func logoutTapped() async {
        guard !isLoggingOut else { return }

        isLoggingOut = true
        defer { isLoggingOut = false }
        do {
            try await logout()
            error = nil
            navigate(.logout)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unexpected(.invariantViolation)
        }
    }

    func sessionExpiredTapped() {
        navigate(.sessionExpired)
    }
}
