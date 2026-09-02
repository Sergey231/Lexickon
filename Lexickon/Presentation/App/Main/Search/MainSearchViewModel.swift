import Observation

@Observable
@MainActor
final class MainSearchViewModel {
    private(set) var isLoggingOut = false
    private(set) var error: AppError?

    private let logoutUseCase: LogoutUseCase
    @ObservationIgnored private let navigate: @MainActor (MainStep) -> Void
    @ObservationIgnored private let navigateToAppStep: @MainActor (AppStep) -> Void

    init(
        logoutUseCase: LogoutUseCase,
        navigate: @escaping @MainActor (MainStep) -> Void,
        navigateToAppStep: @escaping @MainActor (AppStep) -> Void
    ) {
        self.logoutUseCase = logoutUseCase
        self.navigate = navigate
        self.navigateToAppStep = navigateToAppStep
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
            navigateToAppStep(.authentication)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unexpected(.invariantViolation)
        }
    }

    func sessionExpiredTapped() {
        navigateToAppStep(.authentication)
    }
}
