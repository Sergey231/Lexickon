import Foundation

struct AppInfrastructure: Sendable {
    let apiClient: APIClient
    let session: SessionController
    let sessionRefresher: any SessionRefreshing
}

enum AppConfiguration {
    static var datasetRegistryURL: URL {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        return applicationSupport
            .appending(path: Bundle.main.bundleIdentifier ?? "com.lexickon.ios", directoryHint: .isDirectory)
            .appending(path: "installed-datasets.json")
    }

    static var apiBaseURL: URL {
        #if DEBUG
        #if targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8000")!
        #else
        return URL(string: "http://192.168.0.101:8000")!
        #endif
        #else
        return URL(string: "https://api.lexickon.invalid")!
        #endif
    }
}
