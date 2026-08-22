import Foundation

/// The only place where the production dependency graph is assembled.
///
/// Product repositories remain unavailable until their endpoints are
/// implemented. Network and session infrastructure are already production
/// implementations and can be injected into those repositories later without
/// changing feature initializers.
@MainActor
enum ProductionAssembly {
    static func makeContainer(
        baseURL: URL = AppConfiguration.apiBaseURL,
        transport: any HTTPTransport = URLSessionTransport()
    ) -> AppContainer {
        let tokenStore = KeychainTokenStore(
            service: Bundle.main.bundleIdentifier ?? "com.lexickon.ios"
        )
        let session = SessionController(tokenStore: tokenStore)
        let infrastructure = AppInfrastructure(
            apiClient: APIClient(
                baseURL: baseURL,
                transport: transport,
                session: session
            ),
            session: session,
            sessionRefresher: RefreshNotConfigured()
        )
        let repositories = AppRepositories(
            auth: UnavailableAuthRepository(),
            user: UnavailableUserRepository(),
            dataset: UnavailableDatasetRepository(),
            frequency: UnavailableFrequencyRepository()
        )

        return AppContainer(
            repositories: repositories,
            infrastructure: infrastructure
        )
    }
}
