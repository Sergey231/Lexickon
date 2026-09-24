import FactoryKit
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
        let container = Container.shared
        container.apiBaseURL.register { baseURL }
        container.httpTransport.register { transport }
        return AppContainer()
    }
}
