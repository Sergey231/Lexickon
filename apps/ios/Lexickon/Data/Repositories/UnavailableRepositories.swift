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

struct UnavailableDatasetCatalogRepository: DatasetCatalogRepository {
    func catalog() async throws -> DatasetManifest {
        throw dependencyUnavailable(.datasetCatalogRepository)
    }

    func availability(
        installed: [InstalledDataset],
        wanted: [WantedDataset]
    ) async throws -> DatasetSyncAvailability {
        throw dependencyUnavailable(.datasetCatalogRepository)
    }

    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL {
        throw dependencyUnavailable(.datasetCatalogRepository)
    }
}

struct UnavailableInstalledDatasetRepository: InstalledDatasetRepository {
    func datasets() async throws -> [InstalledDataset] {
        throw dependencyUnavailable(.installedDatasetRepository)
    }

    func apply(_ plan: DatasetSyncPlan) async throws {
        throw dependencyUnavailable(.installedDatasetRepository)
    }
}

struct UnavailableFrequencyRepository: FrequencyRepository {
    func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult? {
        throw dependencyUnavailable(.frequencyRepository)
    }
}
