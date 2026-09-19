/// Composition root output. SwiftUI receives only use cases through Environment.
@MainActor
final class AppContainer {
    let dataSources: DataSourcesAssembly
    let repositories: RepositoriesAssembly
    let useCases: UseCases
    let infrastructure: AppInfrastructure

    init(dataSources: DataSourcesAssembly) {
        let repositories = RepositoriesAssembly(dataSources: dataSources)
        let useCases = UseCases(repositories: repositories)
        self.dataSources = dataSources
        self.repositories = repositories
        self.useCases = useCases
        self.infrastructure = dataSources.infrastructure
    }

    /// Этот конструктор использутеся только для тестов.
    init(dataSources: DataSourcesAssembly, repositories: RepositoriesAssembly) {
        let useCases = UseCases(repositories: repositories)
        self.dataSources = dataSources
        self.repositories = repositories
        self.useCases = useCases
        self.infrastructure = dataSources.infrastructure
    }
}
