import Foundation

struct RepositoriesAssembly: Sendable {
    let authRepository: any AuthRepository
    let userRepository: any UserRepository
    let datasetCatalogRepository: any DatasetCatalogRepository
    let installedDatasetRepository: any InstalledDatasetRepository
    let frequencyRepository: any FrequencyRepository

    init(dataSources: DataSourcesAssembly) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository") {
            self.authRepository = UITestAuthRepository()
        } else {
            self.authRepository = AuthRepositoryImpl(
                apiClient: dataSources.apiClient,
                session: dataSources.session
            )
        }
        #else
        self.authRepository = AuthRepositoryImpl(
            apiClient: dataSources.apiClient,
            session: dataSources.session
        )
        #endif
        self.userRepository = UnavailableUserRepository()
        self.datasetCatalogRepository = DatasetCatalogRepositoryImpl(
            apiClient: dataSources.apiClient
        )
        self.installedDatasetRepository = InstalledDatasetRepositoryImpl(
            registry: dataSources.datasetRegistry
        )
        self.frequencyRepository = UnavailableFrequencyRepository()
    }

    init(
        authRepository: any AuthRepository,
        userRepository: any UserRepository,
        datasetCatalogRepository: any DatasetCatalogRepository,
        installedDatasetRepository: any InstalledDatasetRepository,
        frequencyRepository: any FrequencyRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.datasetCatalogRepository = datasetCatalogRepository
        self.installedDatasetRepository = installedDatasetRepository
        self.frequencyRepository = frequencyRepository
    }
}
