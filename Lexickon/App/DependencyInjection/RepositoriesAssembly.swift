import Foundation

struct RepositoriesAssembly: Sendable {
    let authRepository: any AuthRepository
    let userRepository: any UserRepository
    let datasetRepository: any DatasetRepository
    let frequencyRepository: any FrequencyRepository

    init(dataSources: DataSourcesAssembly) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository") {
            self.authRepository = UITestAuthRepository()
        } else {
            self.authRepository = RemoteAuthRepository(
                apiClient: dataSources.apiClient,
                session: dataSources.session
            )
        }
        #else
        self.authRepository = RemoteAuthRepository(
            apiClient: dataSources.apiClient,
            session: dataSources.session
        )
        #endif
        self.userRepository = UnavailableUserRepository()
        self.datasetRepository = DatasetRepositoryImpl(
            apiClient: dataSources.apiClient,
            registry: dataSources.datasetRegistry
        )
        self.frequencyRepository = UnavailableFrequencyRepository()
    }

    init(
        authRepository: any AuthRepository,
        userRepository: any UserRepository,
        datasetRepository: any DatasetRepository,
        frequencyRepository: any FrequencyRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.datasetRepository = datasetRepository
        self.frequencyRepository = frequencyRepository
    }
}
