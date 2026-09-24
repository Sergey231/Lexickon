struct LoginRequest: Equatable, Sendable {
    let email: String
    let password: String
}

/// Аутентифицирует пользователя по email/password.
/// - Parameter request: Email и пароль.
/// - Returns: `AuthenticationState` — `.signedIn` с профилем или `.signedOut` при ошибке.
/// - Throws: `AppError` — `.authorization(.invalidCredentials)`, `.authorization(.unverifiedEmail)`,
///   `.transport`, `.validation`.
struct LoginUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: LoginRequest) async throws -> AuthenticationState {
        try await repository.login(request)
    }
}
