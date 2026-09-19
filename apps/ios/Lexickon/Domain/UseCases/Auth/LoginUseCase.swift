struct LoginRequest: Equatable, Sendable {
    let email: String
    let password: String
}

struct LoginUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: LoginRequest) async throws -> AuthenticationState {
        try await repository.login(request)
    }
}
