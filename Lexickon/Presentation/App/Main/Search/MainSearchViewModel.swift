import Observation

@Observable
@MainActor
final class MainSearchViewModel {
    private(set) var isLoggingOut = false
    private(set) var error: AppError?

    private let logoutUseCase: LogoutUseCase
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void

    init(
        logoutUseCase: LogoutUseCase,
        navigate: @escaping @MainActor (MainStep) -> Void
    ) {
        self.logoutUseCase = logoutUseCase
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
            try await logoutUseCase()
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
