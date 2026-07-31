enum DatasetSetupStep: CoordinatorStep {
    case selection
    case installation
    case storageInfo
    case installationDetails
}

enum DatasetSetupCoordinatorResult: Equatable, Sendable {
    case completed
}

enum DatasetSetupSheet: String, Identifiable, Sendable {
    case storageInfo

    var id: Self { self }
}

enum DatasetSetupFullScreenCover: String, Identifiable, Sendable {
    case installationDetails

    var id: Self { self }
}
