import FactoryKit
import FactoryTesting
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
        let container = Container.shared
        container.authRepository.register { authRepository }
        container.userRepository.register { userRepository }
        container.datasetCatalogRepository.register { datasetCatalogRepository }
        container.installedDatasetRepository.register { installedDatasetRepository }
        container.frequencyRepository.register { frequencyRepository }
        container.apiBaseURL.register { URL(string: "https://unit.test")! }
        container.httpTransport.register { URLSessionTransport() }
        container.tokenStore.register { InMemoryTokenStore() }

        let appContainer = AppContainer(useCases: container.useCases())

        return TestAppGraph(
            container: appContainer,
            authRepository: authRepository,
            userRepository: userRepository,
            datasetCatalogRepository: datasetCatalogRepository,
            installedDatasetRepository: installedDatasetRepository,
            frequencyRepository: frequencyRepository
        )
    }

    static func reset() {
        Container.shared.reset()
    }
}
