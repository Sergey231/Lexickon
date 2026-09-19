protocol AuthRepository: Sendable {
    func register(_ request: RegistrationRequest) async throws -> User
    func login(_ request: LoginRequest) async throws -> AuthenticationState
    func logout() async throws
    func authenticationState() async throws -> AuthenticationState
}
