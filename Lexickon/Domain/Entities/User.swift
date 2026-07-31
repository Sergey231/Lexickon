struct User: Equatable, Sendable {
    let id: UserID
    let email: String
    let settings: UserSettings
}
