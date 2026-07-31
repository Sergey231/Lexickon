protocol UserRepository: Sendable {
    func currentUser() async throws -> User
    func updateSettings(_ patch: UserSettingsPatch) async throws -> UserSettings
}
