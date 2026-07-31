struct RegisterUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction(_ request: RegistrationRequest) async throws -> User {
        try await repository.register(request)
    }
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

struct LogoutUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws {
        try await repository.logout()
    }
}

struct GetAuthenticationStateUseCase: Sendable {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> AuthenticationState {
        try await repository.authenticationState()
    }
}
