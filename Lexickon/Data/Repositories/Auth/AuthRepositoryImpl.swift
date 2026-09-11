struct AuthRepositoryImpl: AuthRepository {
    private let apiClient: APIClient
    private let session: SessionController

    init(apiClient: APIClient, session: SessionController) {
        self.apiClient = apiClient
        self.session = session
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        do {
            return try await apiClient
                .send(AuthRegistrationAPIRequest(request))
                .domainModel()
        } catch {
            throw mapAuthError(error)
        }
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        do {
            let response = try await apiClient.send(AuthLoginAPIRequest(request))
            guard let token = AccessToken(rawValue: response.accessToken) else {
                throw AppError.transport(.invalidResponse)
            }
            try await session.establishSession(with: token)
            return .signedIn
        } catch {
            throw mapLoginError(error)
        }
    }

    func logout() async throws {
        do {
            try await session.signOut()
        } catch {
            throw mapStorageError(error)
        }
    }

    func authenticationState() async throws -> AuthenticationState {
        let bootstrapResult: SessionBootstrapResult
        switch await session.currentState() {
        case .signedOut:
            do {
                bootstrapResult = try await session.bootstrap()
            } catch {
                throw mapStorageError(error)
            }
        case .potentiallyValid:
            bootstrapResult = .potentiallyValid
        case .invalid:
            return .signedOut
        }

        guard bootstrapResult == .potentiallyValid else {
            return .signedOut
        }

        do {
            _ = try await apiClient.send(CurrentUserAPIRequest())
            return .signedIn
        } catch NetworkError.unauthorized, NetworkError.unauthenticated {
            return .signedOut
        } catch {
            throw mapAuthError(error)
        }
    }

    private func mapLoginError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        if let networkError = error as? NetworkError {
            switch networkError {
            case .badRequest, .unauthorized:
                return .authorization(.invalidCredentials)
            default:
                return mapNetworkError(networkError)
            }
        }
        return mapStorageError(error)
    }

    private func mapAuthError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        if let networkError = error as? NetworkError {
            switch networkError {
            case let .badRequest(code) where code == "account_conflict":
                return .authorization(.accountConflict)
            case .unauthorized, .unauthenticated:
                return .authorization(.sessionExpired)
            case .forbidden:
                return .authorization(.forbidden)
            default:
                return mapNetworkError(networkError)
            }
        }
        return .unexpected(.invariantViolation)
    }

    private func mapNetworkError(_ error: NetworkError) -> AppError {
        switch error {
        case .cancelled:
            return .cancelled
        case .offline:
            return .transport(.offline)
        case .timedOut:
            return .transport(.timedOut)
        case .transport:
            return .transport(.unreachable)
        case .invalidRequest, .invalidResponse, .decoding, .conflict, .notFound, .badRequest:
            return .transport(.invalidResponse)
        case .unauthenticated:
            return .authorization(.unauthenticated)
        case .unauthorized:
            return .authorization(.sessionExpired)
        case .forbidden:
            return .authorization(.forbidden)
        case let .server(statusCode, _):
            return .transport(.server(statusCode: statusCode))
        case let .unexpectedStatus(statusCode, _):
            return .transport(.server(statusCode: statusCode))
        }
    }

    private func mapStorageError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        guard let tokenStoreError = error as? TokenStoreError else {
            return .unexpected(.invariantViolation)
        }
        switch tokenStoreError {
        case .corrupted:
            return .localStorage(.corrupted)
        case .readFailed:
            return .localStorage(.readFailed)
        case .writeFailed:
            return .localStorage(.writeFailed)
        case .deleteFailed:
            return .localStorage(.writeFailed)
        }
    }
}
