struct RegistrationRequest: Equatable, Sendable {
    let email: String
    let password: String
}

struct RegisterUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: RegistrationRequest) async throws -> User {
        try await repository.register(request)
    }
}
