struct AppFeatureFactories: Sendable {
    let auth: AuthFeatureFactory
    let datasetSetup: DatasetSetupFeatureFactory
    let main: MainFeatureFactory
}

struct AuthFeatureDependencies: Sendable {
    let register: RegisterUseCase
    let login: LoginUseCase
    let authenticationState: GetAuthenticationStateUseCase
}

struct DatasetSetupFeatureDependencies: Sendable {
    let datasetCatalog: GetDatasetCatalogUseCase
    let synchronizeDatasets: SynchronizeDatasetsUseCase
}

struct MainFeatureDependencies: Sendable {
    let logout: LogoutUseCase
    let currentUser: GetCurrentUserUseCase
    let updateUserSettings: UpdateUserSettingsUseCase
    let lookupFrequency: LookupFrequencyUseCase
}

struct AuthFeatureFactory: Sendable {
    let dependencies: AuthFeatureDependencies

    @MainActor
    func makeCoordinator(
        onStep: @escaping @MainActor (AppStep) -> Void
    ) -> AuthCoordinator {
        AuthCoordinator(onStep: onStep)
    }
}

struct DatasetSetupFeatureFactory: Sendable {
    let dependencies: DatasetSetupFeatureDependencies

    @MainActor
    func makeCoordinator(
        onStep: @escaping @MainActor (AppStep) -> Void
    ) -> DatasetSetupCoordinator {
        DatasetSetupCoordinator(onStep: onStep)
    }
}

struct MainFeatureFactory: Sendable {
    let dependencies: MainFeatureDependencies

    @MainActor
    func makeCoordinator(
        onStep: @escaping @MainActor (AppStep) -> Void
    ) -> MainCoordinator {
        MainCoordinator(onStep: onStep)
    }
}
