struct AppRepositories: Sendable {
    let auth: any AuthRepository
    let user: any UserRepository
    let dataset: any DatasetRepository
    let frequency: any FrequencyRepository
}

private struct AppUseCases: Sendable {
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

/// Composition root output. Feature code receives its feature factory; it
/// never receives this container or the complete set of application use cases.
@MainActor
final class AppContainer {
    let featureFactories: AppFeatureFactories
    let infrastructure: AppInfrastructure

    init(repositories: AppRepositories, infrastructure: AppInfrastructure) {
        self.infrastructure = infrastructure
        let useCases = AppUseCases(
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

        featureFactories = AppFeatureFactories(
            auth: AuthFeatureFactory(
                dependencies: AuthFeatureDependencies(
                    register: useCases.register,
                    login: useCases.login,
                    authenticationState: useCases.authenticationState
                )
            ),
            datasetSetup: DatasetSetupFeatureFactory(
                dependencies: DatasetSetupFeatureDependencies(
                    datasetCatalog: useCases.datasetCatalog,
                    synchronizeDatasets: useCases.synchronizeDatasets
                )
            ),
            main: MainFeatureFactory(
                dependencies: MainFeatureDependencies(
                    logout: useCases.logout,
                    currentUser: useCases.currentUser,
                    updateUserSettings: useCases.updateUserSettings,
                    lookupFrequency: useCases.lookupFrequency
                )
            )
        )
    }
}
