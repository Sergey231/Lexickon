import Observation

@Observable
@MainActor
final class MainSessionViewModel {
    private(set) var isLoggingOut = false
    private(set) var error: AppError?

    private let logout: LogoutUseCase

    init(logout: LogoutUseCase) {
        self.logout = logout
    }

    func performLogout() async -> Bool {
        guard !isLoggingOut else { return false }

        isLoggingOut = true
        defer { isLoggingOut = false }
        do {
            try await logout()
            error = nil
            return true
        } catch let appError as AppError {
            error = appError
            return false
        } catch {
            self.error = .unexpected(.invariantViolation)
            return false
        }
    }
}
