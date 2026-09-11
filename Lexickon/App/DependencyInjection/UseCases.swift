import SwiftUI

struct UseCases: Sendable {
    let resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase
    let registerUseCase: RegisterUseCase
    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let currentUserUseCase: GetCurrentUserUseCase
    let updateUserSettingsUseCase: UpdateUserSettingsUseCase
    let datasetCatalogUseCase: GetDatasetCatalogUseCase
    let installedDatasetsUseCase: GetInstalledDatasetsUseCase
    let synchronizeDatasetsUseCase: SynchronizeDatasetsUseCase
    let datasetDownloadURLUseCase: GetDatasetDownloadURLUseCase
    let lookupFrequencyUseCase: LookupFrequencyUseCase

    init(repositories: RepositoriesAssembly) {
        self.resolveLaunchDestinationUseCase = ResolveLaunchDestinationUseCase(
            repository: repositories.authRepository
        )
        self.registerUseCase = RegisterUseCase(repository: repositories.authRepository)
        self.loginUseCase = LoginUseCase(repository: repositories.authRepository)
        self.logoutUseCase = LogoutUseCase(repository: repositories.authRepository)
        self.currentUserUseCase = GetCurrentUserUseCase(
            repository: repositories.userRepository
        )
        self.updateUserSettingsUseCase = UpdateUserSettingsUseCase(
            repository: repositories.userRepository
        )
        self.datasetCatalogUseCase = GetDatasetCatalogUseCase(
            repository: repositories.datasetCatalogRepository
        )
        self.installedDatasetsUseCase = GetInstalledDatasetsUseCase(
            repository: repositories.installedDatasetRepository
        )
        self.synchronizeDatasetsUseCase = SynchronizeDatasetsUseCase(
            catalogRepository: repositories.datasetCatalogRepository,
            installedRepository: repositories.installedDatasetRepository
        )
        self.datasetDownloadURLUseCase = GetDatasetDownloadURLUseCase(
            repository: repositories.datasetCatalogRepository
        )
        self.lookupFrequencyUseCase = LookupFrequencyUseCase(
            repository: repositories.frequencyRepository
        )
    }

    static let unavailable = UseCases(
        repositories: RepositoriesAssembly(
            authRepository: UnavailableAuthRepository(),
            userRepository: UnavailableUserRepository(),
            datasetCatalogRepository: UnavailableDatasetCatalogRepository(),
            installedDatasetRepository: UnavailableInstalledDatasetRepository(),
            frequencyRepository: UnavailableFrequencyRepository()
        )
    )
}

private struct UseCasesKey: EnvironmentKey {
    static let defaultValue = UseCases.unavailable
}

extension EnvironmentValues {
    var useCases: UseCases {
        get { self[UseCasesKey.self] }
        set { self[UseCasesKey.self] = newValue }
    }
}
