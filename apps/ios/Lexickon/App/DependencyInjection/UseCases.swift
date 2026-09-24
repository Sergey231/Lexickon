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

    static let unavailable = UseCases(
        resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase(repository: UnavailableAuthRepository()),
        registerUseCase: RegisterUseCase(repository: UnavailableAuthRepository()),
        loginUseCase: LoginUseCase(repository: UnavailableAuthRepository()),
        logoutUseCase: LogoutUseCase(repository: UnavailableAuthRepository()),
        currentUserUseCase: GetCurrentUserUseCase(repository: UnavailableUserRepository()),
        updateUserSettingsUseCase: UpdateUserSettingsUseCase(repository: UnavailableUserRepository()),
        datasetCatalogUseCase: GetDatasetCatalogUseCase(repository: UnavailableDatasetCatalogRepository()),
        installedDatasetsUseCase: GetInstalledDatasetsUseCase(repository: UnavailableInstalledDatasetRepository()),
        synchronizeDatasetsUseCase: SynchronizeDatasetsUseCase(
            catalogRepository: UnavailableDatasetCatalogRepository(),
            installedRepository: UnavailableInstalledDatasetRepository()
        ),
        datasetDownloadURLUseCase: GetDatasetDownloadURLUseCase(repository: UnavailableDatasetCatalogRepository()),
        lookupFrequencyUseCase: LookupFrequencyUseCase(repository: UnavailableFrequencyRepository())
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
