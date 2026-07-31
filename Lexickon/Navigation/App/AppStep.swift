enum AppStep: CoordinatorStep {
    case showAuthentication
    case showDatasetSetup
    case showMain
    case logout
    case sessionExpired
}

enum AppRoot: Equatable, Sendable {
    case authentication
    case datasetSetup
    case main
}
