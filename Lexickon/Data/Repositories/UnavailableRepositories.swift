private func dependencyUnavailable(_ dependency: Dependency) -> AppError {
    .unexpected(.dependencyNotConfigured(dependency))
}

struct UnavailableAuthRepository: AuthRepository {
    func register(_ request: RegistrationRequest) async throws -> User {
        throw dependencyUnavailable(.authRepository)
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        throw dependencyUnavailable(.authRepository)
    }

    func logout() async throws {
        throw dependencyUnavailable(.authRepository)
    }

    func authenticationState() async throws -> AuthenticationState {
        throw dependencyUnavailable(.authRepository)
    }
}

struct UnavailableUserRepository: UserRepository {
    func currentUser() async throws -> User {
        throw dependencyUnavailable(.userRepository)
    }

    func updateSettings(_ patch: UserSettingsPatch) async throws -> UserSettings {
        throw dependencyUnavailable(.userRepository)
    }
}

struct UnavailableDatasetRepository: DatasetRepository {
    func catalog() async throws -> [Dataset] {
        throw dependencyUnavailable(.datasetRepository)
    }

    func synchronize(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult {
        throw dependencyUnavailable(.datasetRepository)
    }
}

struct UnavailableFrequencyRepository: FrequencyRepository {
    func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult? {
        throw dependencyUnavailable(.frequencyRepository)
    }
}
