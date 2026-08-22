import Foundation

struct AppInfrastructure: Sendable {
    let apiClient: APIClient
    let session: SessionController
    let sessionRefresher: any SessionRefreshing
}

enum AppConfiguration {
    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "http://127.0.0.1:8000")!
        #else
        return URL(string: "https://api.lexickon.invalid")!
        #endif
    }
}
