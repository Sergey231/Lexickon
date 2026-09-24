/// Возвращает профиль текущего авторизованного пользователя.
/// - Returns: `User` с email, настройками, планом доступа.
/// - Throws: `AppError` — `.authorization(.unauthenticated)` если сессии нет,
///   `.authorization(.sessionExpired)`, `.transport`.
struct GetCurrentUserUseCase: Sendable {
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> User {
        try await repository.currentUser()
    }
}
