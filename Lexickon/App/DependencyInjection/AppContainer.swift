struct AppRepositories: Sendable {
    let auth: any AuthRepository
    let user: any UserRepository
    let dataset: any DatasetRepository
    let frequency: any FrequencyRepository
}

struct AppUseCases: Sendable {
    let register: RegisterUseCase
    let login: LoginUseCase
    let logout: LogoutUseCase
    let authenticationState: GetAuthenticationStateUseCase
    let currentUser: GetCurrentUserUseCase
    let updateUserSettings: UpdateUserSettingsUseCase
    let datasetCatalog: GetDatasetCatalogUseCase
    let synchronizeDatasets: SynchronizeDatasetsUseCase
    let lookupFrequency: LookupFrequencyUseCase
}

/// Composition root output. Feature code receives individual use cases from a
/// feature factory; it never receives this container.
@MainActor
final class AppContainer {
    let useCases: AppUseCases

    init(repositories: AppRepositories) {
        useCases = AppUseCases(
            register: RegisterUseCase(repository: repositories.auth),
            login: LoginUseCase(repository: repositories.auth),
            logout: LogoutUseCase(repository: repositories.auth),
            authenticationState: GetAuthenticationStateUseCase(
                repository: repositories.auth
            ),
            currentUser: GetCurrentUserUseCase(repository: repositories.user),
            updateUserSettings: UpdateUserSettingsUseCase(
                repository: repositories.user
            ),
            datasetCatalog: GetDatasetCatalogUseCase(
                repository: repositories.dataset
            ),
            synchronizeDatasets: SynchronizeDatasetsUseCase(
                repository: repositories.dataset
            ),
            lookupFrequency: LookupFrequencyUseCase(
                repository: repositories.frequency
            )
        )
    }
}
