import Foundation

/// The only place where the production dependency graph is assembled.
///
/// Network, session and dataset-catalog dependencies are production adapters.
/// Repositories for later product stages remain explicit unavailable adapters.
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
