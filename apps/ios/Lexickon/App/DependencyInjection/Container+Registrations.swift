import FactoryKit
import Foundation

extension Container {
    // MARK: - Infrastructure
    var apiBaseURL: Factory<URL> {
        self { AppConfiguration.apiBaseURL }
    }

    var httpTransport: Factory<any HTTPTransport> {
        self { URLSessionTransport() }
    }

    var tokenStore: Factory<any TokenStore> {
        self { KeychainTokenStore(service: Bundle.main.bundleIdentifier ?? "com.lexickon.ios") }
    }

    var sessionRefresher: Factory<any SessionRefreshing> {
        self { RefreshNotConfigured() }
    }

    var datasetRegistryURL: Factory<URL> {
        self { AppConfiguration.datasetRegistryURL }
    }

    var datasetRegistry: Factory<any InstalledDatasetRegistry> {
        self { FileInstalledDatasetRegistry(fileURL: self.datasetRegistryURL()) }
    }

    // MARK: - Data Sources
    var sessionController: Factory<SessionController> {
        self { SessionController(tokenStore: self.tokenStore()) }
    }

    var apiClient: Factory<APIClient> {
        self {
            APIClient(
                baseURL: self.apiBaseURL(),
                transport: self.httpTransport(),
                session: self.sessionController()
            )
        }
    }

    var dataSourcesAssembly: Factory<DataSourcesAssembly> {
        self {
            DataSourcesAssembly(
                baseURL: self.apiBaseURL(),
                transport: self.httpTransport(),
                tokenStore: self.tokenStore(),
                sessionRefresher: self.sessionRefresher(),
                datasetRegistry: self.datasetRegistry()
            )
        }
    }

    // MARK: - Repositories
    var authRepository: Factory<any AuthRepository> {
        self {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository") {
                return UITestAuthRepository()
            }
            #endif
            return AuthRepositoryImpl(
                apiClient: self.apiClient(),
                session: self.sessionController()
            )
        }
    }

    var userRepository: Factory<any UserRepository> {
        self { UnavailableUserRepository() }
    }

    var datasetCatalogRepository: Factory<any DatasetCatalogRepository> {
        self { DatasetCatalogRepositoryImpl(apiClient: self.apiClient()) }
    }

    var installedDatasetRepository: Factory<any InstalledDatasetRepository> {
        self { InstalledDatasetRepositoryImpl(registry: self.datasetRegistry()) }
    }

    var frequencyRepository: Factory<any FrequencyRepository> {
        self { UnavailableFrequencyRepository() }
    }

    var repositoriesAssembly: Factory<RepositoriesAssembly> {
        self {
            RepositoriesAssembly(
                authRepository: self.authRepository(),
                userRepository: self.userRepository(),
                datasetCatalogRepository: self.datasetCatalogRepository(),
                installedDatasetRepository: self.installedDatasetRepository(),
                frequencyRepository: self.frequencyRepository()
            )
        }
    }

    // MARK: - Use Cases
    var resolveLaunchDestinationUseCase: Factory<ResolveLaunchDestinationUseCase> {
        self { ResolveLaunchDestinationUseCase(repository: self.authRepository()) }
    }

    var registerUseCase: Factory<RegisterUseCase> {
        self { RegisterUseCase(repository: self.authRepository()) }
    }

    var loginUseCase: Factory<LoginUseCase> {
        self { LoginUseCase(repository: self.authRepository()) }
    }

    var logoutUseCase: Factory<LogoutUseCase> {
        self { LogoutUseCase(repository: self.authRepository()) }
    }

    var currentUserUseCase: Factory<GetCurrentUserUseCase> {
        self { GetCurrentUserUseCase(repository: self.userRepository()) }
    }

    var updateUserSettingsUseCase: Factory<UpdateUserSettingsUseCase> {
        self { UpdateUserSettingsUseCase(repository: self.userRepository()) }
    }

    var datasetCatalogUseCase: Factory<GetDatasetCatalogUseCase> {
        self { GetDatasetCatalogUseCase(repository: self.datasetCatalogRepository()) }
    }

    var installedDatasetsUseCase: Factory<GetInstalledDatasetsUseCase> {
        self { GetInstalledDatasetsUseCase(repository: self.installedDatasetRepository()) }
    }

    var synchronizeDatasetsUseCase: Factory<SynchronizeDatasetsUseCase> {
        self {
            SynchronizeDatasetsUseCase(
                catalogRepository: self.datasetCatalogRepository(),
                installedRepository: self.installedDatasetRepository()
            )
        }
    }

    var datasetDownloadURLUseCase: Factory<GetDatasetDownloadURLUseCase> {
        self { GetDatasetDownloadURLUseCase(repository: self.datasetCatalogRepository()) }
    }

    var lookupFrequencyUseCase: Factory<LookupFrequencyUseCase> {
        self { LookupFrequencyUseCase(repository: self.frequencyRepository()) }
    }

    var useCases: Factory<UseCases> {
        self {
            UseCases(
                resolveLaunchDestinationUseCase: self.resolveLaunchDestinationUseCase(),
                registerUseCase: self.registerUseCase(),
                loginUseCase: self.loginUseCase(),
                logoutUseCase: self.logoutUseCase(),
                currentUserUseCase: self.currentUserUseCase(),
                updateUserSettingsUseCase: self.updateUserSettingsUseCase(),
                datasetCatalogUseCase: self.datasetCatalogUseCase(),
                installedDatasetsUseCase: self.installedDatasetsUseCase(),
                synchronizeDatasetsUseCase: self.synchronizeDatasetsUseCase(),
                datasetDownloadURLUseCase: self.datasetDownloadURLUseCase(),
                lookupFrequencyUseCase: self.lookupFrequencyUseCase()
            )
        }
    }
}