struct GetCurrentUserUseCase: Sendable {
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> User {
        try await repository.currentUser()
    }
}

struct UpdateUserSettingsUseCase: Sendable {
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func callAsFunction(_ patch: UserSettingsPatch) async throws -> UserSettings {
        try await repository.updateSettings(patch)
    }
}
