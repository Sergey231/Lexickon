import Foundation
@testable import Lexickon

struct TestAppGraph {
    let container: AppContainer
    let authRepository: AuthRepositoryStub
    let userRepository: UserRepositoryStub
    let datasetCatalogRepository: DatasetCatalogRepositoryStub
    let installedDatasetRepository: InstalledDatasetRepositoryStub
    let frequencyRepository: FrequencyRepositoryStub
}

@MainActor
enum TestAssembly {
    static func makeGraph(
        authRepository: AuthRepositoryStub,
        userRepository: UserRepositoryStub,
        datasetCatalogRepository: DatasetCatalogRepositoryStub,
        installedDatasetRepository: InstalledDatasetRepositoryStub,
        frequencyRepository: FrequencyRepositoryStub
    ) -> TestAppGraph {
        let dataSources = DataSourcesAssembly(
            baseURL: URL(string: "https://unit.test")!,
            transport: URLSessionTransport(),
            tokenStore: InMemoryTokenStore()
        )
        let repositories = RepositoriesAssembly(
            authRepository: authRepository,
            userRepository: userRepository,
            datasetCatalogRepository: datasetCatalogRepository,
            installedDatasetRepository: installedDatasetRepository,
            frequencyRepository: frequencyRepository
        )
        let container = AppContainer(
            dataSources: dataSources,
            repositories: repositories
        )

        return TestAppGraph(
            container: container,
            authRepository: authRepository,
            userRepository: userRepository,
            datasetCatalogRepository: datasetCatalogRepository,
            installedDatasetRepository: installedDatasetRepository,
            frequencyRepository: frequencyRepository
        )
    }
}
