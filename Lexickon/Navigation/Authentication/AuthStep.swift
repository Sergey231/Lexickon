enum AuthStep: CoordinatorStep {
    case login
    case registration
    case help
    case privacy
}

enum AuthCoordinatorResult: Equatable, Sendable {
    case authenticated
}

enum AuthSheet: String, Identifiable, Sendable {
    case help

    var id: Self { self }
}

enum AuthFullScreenCover: String, Identifiable, Sendable {
    case privacy

    var id: Self { self }
}
