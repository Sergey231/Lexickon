enum MainStep: CoordinatorStep {
    case frequency
    case profile
    case settings
    case about
    case onboarding
    case selectTab(MainTab)
}

enum MainTab: String, Hashable, Sendable {
    case search
    case frequency
    case profile
}

enum MainCoordinatorResult: Equatable, Sendable {
    case logout
    case sessionExpired
}

enum MainSheet: String, Identifiable, Sendable {
    case about

    var id: Self { self }
}

enum MainFullScreenCover: String, Identifiable, Sendable {
    case onboarding

    var id: Self { self }
}
