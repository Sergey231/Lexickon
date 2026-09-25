import FactoryKit
import Foundation

private func dependencyUnavailable(_ dependency: Dependency) -> AppError {
    .unexpected(.dependencyNotConfigured(dependency))
}

extension Container {
    // MARK: - Infrastructure (singleton)
    var apiBaseURL: Factory<URL> {
        self { AppConfiguration.apiBaseURL }.singleton
    }

    var httpTransport: Factory<any HTTPTransport> {
        self { URLSessionTransport() }.singleton
    }

    var tokenStore: Factory<any TokenStore> {
        self { KeychainTokenStore(service: Bundle.main.bundleIdentifier ?? "com.lexickon.ios") }.singleton
    }

    var sessionRefresher: Factory<any SessionRefreshing> {
        self { RefreshNotConfigured() }.cached
    }

    var datasetRegistryURL: Factory<URL> {
        self { AppConfiguration.datasetRegistryURL }.cached
    }

    var datasetRegistry: Factory<any InstalledDatasetRegistry> {
        self { FileInstalledDatasetRegistry(fileURL: self.datasetRegistryURL()) }.cached
    }

    // MARK: - Data Sources (cached)
    var sessionController: Factory<SessionController> {
        self { SessionController(tokenStore: self.tokenStore()) }.cached
    }

    var apiClient: Factory<APIClient> {
        self {
            APIClient(
                baseURL: self.apiBaseURL(),
                transport: self.httpTransport(),
                session: self.sessionController()
            )
        }.cached
    }

    // MARK: - Repositories (cached)
    var authRepository: Factory<any AuthRepository> {
        self {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository") {
                return UITestAuthRepository() as any AuthRepository
            }
            #endif
            return AuthRepositoryImpl(
                apiClient: self.apiClient(),
                session: self.sessionController()
            ) as any AuthRepository
        }.cached
    }

    var userRepository: Factory<any UserRepository> {
        self {
            struct UnimplementedUserRepository: UserRepository {
                func currentUser() async throws -> User {
                    throw dependencyUnavailable(.userRepository)
                }
                func updateSettings(_ patch: UserSettingsPatch) async throws -> UserSettings {
                    throw dependencyUnavailable(.userRepository)
                }
            }
            return UnimplementedUserRepository() as any UserRepository
        }.cached
    }

    var datasetCatalogRepository: Factory<any DatasetCatalogRepository> {
        self { DatasetCatalogRepositoryImpl(apiClient: self.apiClient()) as any DatasetCatalogRepository }.cached
    }

    var installedDatasetRepository: Factory<any InstalledDatasetRepository> {
        self { InstalledDatasetRepositoryImpl(registry: self.datasetRegistry()) as any InstalledDatasetRepository }.cached
    }

    var frequencyRepository: Factory<any FrequencyRepository> {
        self {
            struct UnimplementedFrequencyRepository: FrequencyRepository {
                func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult? {
                    throw dependencyUnavailable(.frequencyRepository)
                }
            }
            return UnimplementedFrequencyRepository() as any FrequencyRepository
        }.cached
    }

    // MARK: - Use Cases (cached)
    var resolveLaunchDestinationUseCase: Factory<ResolveLaunchDestinationUseCase> {
        self { ResolveLaunchDestinationUseCase(repository: self.authRepository()) }.cached
    }

    var registerUseCase: Factory<RegisterUseCase> {
        self { RegisterUseCase(repository: self.authRepository()) }.cached
    }

    var loginUseCase: Factory<LoginUseCase> {
        self { LoginUseCase(repository: self.authRepository()) }.cached
    }

    var logoutUseCase: Factory<LogoutUseCase> {
        self { LogoutUseCase(repository: self.authRepository()) }.cached
    }

    var currentUserUseCase: Factory<GetCurrentUserUseCase> {
        self { GetCurrentUserUseCase(repository: self.userRepository()) }.cached
    }

    var updateUserSettingsUseCase: Factory<UpdateUserSettingsUseCase> {
        self { UpdateUserSettingsUseCase(repository: self.userRepository()) }.cached
    }

    var datasetCatalogUseCase: Factory<GetDatasetCatalogUseCase> {
        self { GetDatasetCatalogUseCase(repository: self.datasetCatalogRepository()) }.cached
    }

    var installedDatasetsUseCase: Factory<GetInstalledDatasetsUseCase> {
        self { GetInstalledDatasetsUseCase(repository: self.installedDatasetRepository()) }.cached
    }

    var synchronizeDatasetsUseCase: Factory<SynchronizeDatasetsUseCase> {
        self {
            SynchronizeDatasetsUseCase(
                catalogRepository: self.datasetCatalogRepository(),
                installedRepository: self.installedDatasetRepository()
            )
        }.cached
    }

    var datasetDownloadURLUseCase: Factory<GetDatasetDownloadURLUseCase> {
        self { GetDatasetDownloadURLUseCase(repository: self.datasetCatalogRepository()) }.cached
    }

    var lookupFrequencyUseCase: Factory<LookupFrequencyUseCase> {
        self { LookupFrequencyUseCase(repository: self.frequencyRepository()) }.cached
    }
}