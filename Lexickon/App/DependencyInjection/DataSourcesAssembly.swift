import Foundation

struct DataSourcesAssembly: Sendable {
    let apiClient: APIClient
    let session: SessionController
    let sessionRefresher: any SessionRefreshing
    let datasetRegistry: any InstalledDatasetRegistry

    init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        transport: any HTTPTransport = URLSessionTransport(),
        tokenStore: any TokenStore = KeychainTokenStore(
            service: Bundle.main.bundleIdentifier ?? "com.lexickon.ios"
        ),
        sessionRefresher: any SessionRefreshing = RefreshNotConfigured(),
        datasetRegistry: any InstalledDatasetRegistry = FileInstalledDatasetRegistry(
            fileURL: AppConfiguration.datasetRegistryURL
        )
    ) {
        let session = SessionController(tokenStore: tokenStore)
        self.session = session
        self.apiClient = APIClient(
            baseURL: baseURL,
            transport: transport,
            session: session
        )
        self.sessionRefresher = sessionRefresher
        self.datasetRegistry = datasetRegistry
    }

    var infrastructure: AppInfrastructure {
        AppInfrastructure(
            apiClient: apiClient,
            session: session,
            sessionRefresher: sessionRefresher
        )
    }
}
