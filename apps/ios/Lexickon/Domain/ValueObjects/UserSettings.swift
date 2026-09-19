struct UserSettings: Equatable, Sendable {
    let preferredLanguage: LanguageCode
    let selectedDomains: [DatasetDomain]
    let offlineMode: Bool
    let syncOverCellular: Bool
}
