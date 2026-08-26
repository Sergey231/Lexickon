import SwiftUI

struct UseCases: Sendable {
    let resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase
    let registerUseCase: RegisterUseCase
    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let currentUserUseCase: GetCurrentUserUseCase
    let updateUserSettingsUseCase: UpdateUserSettingsUseCase
    let datasetCatalogUseCase: GetDatasetCatalogUseCase
    let synchronizeDatasetsUseCase: SynchronizeDatasetsUseCase
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
            repository: repositories.datasetRepository
        )
        self.synchronizeDatasetsUseCase = SynchronizeDatasetsUseCase(
            repository: repositories.datasetRepository
        )
        self.lookupFrequencyUseCase = LookupFrequencyUseCase(
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
