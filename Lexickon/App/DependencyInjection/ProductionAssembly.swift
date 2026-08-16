/// The only place where the production dependency graph is assembled.
///
/// Later stages replace the unavailable adapters with network, Keychain, and
/// SQLite implementations without changing feature initializers.
@MainActor
enum ProductionAssembly {
    static func makeContainer() -> AppContainer {
        let repositories = AppRepositories(
            auth: UnavailableAuthRepository(),
            user: UnavailableUserRepository(),
            dataset: UnavailableDatasetRepository(),
            frequency: UnavailableFrequencyRepository()
        )

        return AppContainer(repositories: repositories)
    }
}
