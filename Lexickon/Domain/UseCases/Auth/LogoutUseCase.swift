struct LogoutUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws {
        try await repository.logout()
    }
}
