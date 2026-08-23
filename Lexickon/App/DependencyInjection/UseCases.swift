import SwiftUI

struct UseCases: Sendable {
    let resolveLaunchDestination: ResolveLaunchDestinationUseCase
    let register: RegisterUseCase
    let login: LoginUseCase
    let logout: LogoutUseCase
    let currentUser: GetCurrentUserUseCase
    let updateUserSettings: UpdateUserSettingsUseCase
    let datasetCatalog: GetDatasetCatalogUseCase
    let synchronizeDatasets: SynchronizeDatasetsUseCase
    let lookupFrequency: LookupFrequencyUseCase

    init(repositories: RepositoriesAssembly) {
        self.resolveLaunchDestination = ResolveLaunchDestinationUseCase(
            repository: repositories.authRepository
        )
        self.register = RegisterUseCase(repository: repositories.authRepository)
        self.login = LoginUseCase(repository: repositories.authRepository)
        self.logout = LogoutUseCase(repository: repositories.authRepository)
        self.currentUser = GetCurrentUserUseCase(
            repository: repositories.userRepository
        )
        self.updateUserSettings = UpdateUserSettingsUseCase(
            repository: repositories.userRepository
        )
        self.datasetCatalog = GetDatasetCatalogUseCase(
            repository: repositories.datasetRepository
        )
        self.synchronizeDatasets = SynchronizeDatasetsUseCase(
            repository: repositories.datasetRepository
        )
        self.lookupFrequency = LookupFrequencyUseCase(
            repository: repositories.frequencyRepository
        )
    }

    static let unavailable = UseCases(
        repositories: RepositoriesAssembly(
            authRepository: UnavailableAuthRepository(),
            userRepository: UnavailableUserRepository(),
            datasetRepository: UnavailableDatasetRepository(),
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
