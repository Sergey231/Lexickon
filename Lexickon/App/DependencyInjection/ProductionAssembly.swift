import Foundation

/// The only place where the production dependency graph is assembled.
///
/// Product repositories remain unavailable until their endpoints are
/// implemented. Network and session infrastructure are already production
/// implementations and can be injected into those repositories later without
/// changing presentation assemblies.
@MainActor
enum ProductionAssembly {
    static func makeContainer(
        baseURL: URL = AppConfiguration.apiBaseURL,
        transport: any HTTPTransport = URLSessionTransport()
    ) -> AppContainer {
        let dataSources = DataSourcesAssembly(
            baseURL: baseURL,
            transport: transport
        )

        return AppContainer(dataSources: dataSources)
    }
}
