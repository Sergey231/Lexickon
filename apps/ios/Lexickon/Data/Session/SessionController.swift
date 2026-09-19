enum SessionState: Equatable, Sendable {
    case signedOut
    case potentiallyValid
    case invalid(SessionInvalidationReason)
}

enum SessionInvalidationReason: Equatable, Sendable {
    case unauthorized
    case corruptedToken
}

enum SessionBootstrapResult: Equatable, Sendable {
    case absent
    case potentiallyValid
    case invalid
}

actor SessionController: SessionAuthorizing {
    private let tokenStore: any TokenStore
    private var token: AccessToken?
    private var state: SessionState = .signedOut

    init(tokenStore: any TokenStore) {
        self.tokenStore = tokenStore
    }

    func bootstrap() async throws -> SessionBootstrapResult {
        do {
            guard let storedToken = try await tokenStore.loadAccessToken() else {
                token = nil
                state = .signedOut
                return .absent
            }
            token = storedToken
            state = .potentiallyValid
            return .potentiallyValid
        } catch TokenStoreError.corrupted {
            try await tokenStore.deleteAccessToken()
            token = nil
            state = .invalid(.corruptedToken)
            return .invalid
        }
    }

    func establishSession(with token: AccessToken) async throws {
        try await tokenStore.saveAccessToken(token)
        self.token = token
        state = .potentiallyValid
    }

    func signOut() async throws {
        try await tokenStore.deleteAccessToken()
        token = nil
        state = .signedOut
    }

    func currentState() -> SessionState {
        state
    }

    func bearerToken() -> AccessToken? {
        token
    }

    func didReceiveUnauthorized() async {
        try? await tokenStore.deleteAccessToken()
        token = nil
        state = .invalid(.unauthorized)
    }
}
