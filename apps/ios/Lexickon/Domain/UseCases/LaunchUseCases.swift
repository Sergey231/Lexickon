enum LaunchDestination: Hashable, Sendable {
    case login
    case main
}

/// Определяет экран при запуске приложения на основе состояния аутентификации.
/// - Returns: `.main` если пользователь авторизован, `.login` — иначе.
/// - Throws: `AppError` из `AuthRepository.authenticationState()`.
struct ResolveLaunchDestinationUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> LaunchDestination {
        switch try await repository.authenticationState() {
        case .signedIn:
            return .main
        case .signedOut:
            return .login
        }
    }
}
