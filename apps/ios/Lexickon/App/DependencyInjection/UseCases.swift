import Foundation

private struct UnavailableAuthRepository: AuthRepository {
    func register(_ request: RegistrationRequest) async throws -> User { throw AppError.unexpected(.dependencyNotConfigured(.authRepository)) }
    func login(_ request: LoginRequest) async throws -> AuthenticationState { throw AppError.unexpected(.dependencyNotConfigured(.authRepository)) }
    func logout() async throws { throw AppError.unexpected(.dependencyNotConfigured(.authRepository)) }
    func authenticationState() async throws -> AuthenticationState { throw AppError.unexpected(.dependencyNotConfigured(.authRepository)) }
}

private struct UnavailableUserRepository: UserRepository {
    func currentUser() async throws -> User { throw AppError.unexpected(.dependencyNotConfigured(.userRepository)) }
    func updateSettings(_ patch: UserSettingsPatch) async throws -> UserSettings { throw AppError.unexpected(.dependencyNotConfigured(.userRepository)) }
}

private struct UnavailableDatasetCatalogRepository: DatasetCatalogRepository {
    func catalog() async throws -> DatasetManifest { throw AppError.unexpected(.dependencyNotConfigured(.datasetCatalogRepository)) }
    func availability(installed: [InstalledDataset], wanted: [WantedDataset]) async throws -> DatasetSyncAvailability { throw AppError.unexpected(.dependencyNotConfigured(.datasetCatalogRepository)) }
    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL { throw AppError.unexpected(.dependencyNotConfigured(.datasetCatalogRepository)) }
}

private struct UnavailableInstalledDatasetRepository: InstalledDatasetRepository {
    func datasets() async throws -> [InstalledDataset] { throw AppError.unexpected(.dependencyNotConfigured(.installedDatasetRepository)) }
    func apply(_ plan: DatasetSyncPlan) async throws { throw AppError.unexpected(.dependencyNotConfigured(.installedDatasetRepository)) }
}

private struct UnavailableFrequencyRepository: FrequencyRepository {
    func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult? { throw AppError.unexpected(.dependencyNotConfigured(.frequencyRepository)) }
}