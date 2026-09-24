struct RegistrationRequest: Equatable, Sendable {
    let email: String
    let password: String
}

/// Регистрирует нового пользователя.
/// - Parameter request: Email и пароль.
/// - Returns: `User` созданного аккаунта (обычно требует верификации email).
/// - Throws: `AppError` — `.authorization(.emailAlreadyExists)`, `.validation`,
///   `.transport`.
struct RegisterUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: RegistrationRequest) async throws -> User {
        try await repository.register(request)
    }
}
