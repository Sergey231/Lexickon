struct GetCurrentUserUseCase: Sendable {
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> User {
        try await repository.currentUser()
    }
}
