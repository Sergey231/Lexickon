/// Выполняет выход пользователя: удаляет токены, чистит локальное состояние.
/// - Throws: `AppError` — `.authorization`, `.transport` (игнорируется серверный ответ).
struct LogoutUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws {
        try await repository.logout()
    }
}
