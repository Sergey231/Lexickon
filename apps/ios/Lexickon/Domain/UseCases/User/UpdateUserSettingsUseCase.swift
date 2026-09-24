struct UserSettingsPatch: Equatable, Sendable {
    var preferredLanguage: LanguageCode?
    var selectedDomains: [DatasetDomain]?
    var offlineMode: Bool?
    var syncOverCellular: Bool?

    init(
        preferredLanguage: LanguageCode? = nil,
        selectedDomains: [DatasetDomain]? = nil,
        offlineMode: Bool? = nil,
        syncOverCellular: Bool? = nil
    ) {
        self.preferredLanguage = preferredLanguage
        self.selectedDomains = selectedDomains
        self.offlineMode = offlineMode
        self.syncOverCellular = syncOverCellular
    }
}

/// Частично обновляет настройки пользователя.
/// - Parameter patch: Поля для обновления (nil — не менять).
/// - Returns: Актуальные `UserSettings` после применения.
/// - Throws: `AppError` — `.authorization(.unauthenticated)` если нет сессии,
///   `.transport`, `.validation` ошибки валидации полей.
struct UpdateUserSettingsUseCase: Sendable {
    private let repository: any UserRepository

    init(repository: any UserRepository) {
        self.repository = repository
    }

    func callAsFunction(_ patch: UserSettingsPatch) async throws -> UserSettings {
        try await repository.updateSettings(patch)
    }
}
