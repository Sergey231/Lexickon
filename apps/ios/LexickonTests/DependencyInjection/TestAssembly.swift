import FactoryKit
import FactoryTesting
import Foundation
import XCTest
@testable import Lexickon

struct TestAppGraph {
    let authRepository: AuthRepositoryStub
    let userRepository: UserRepositoryStub
    let datasetCatalogRepository: DatasetCatalogRepositoryStub
    let installedDatasetRepository: InstalledDatasetRepositoryStub
    let frequencyRepository: FrequencyRepositoryStub
}

enum TestAssembly {
    @MainActor
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

        return TestAppGraph(
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

open class BaseTestCase: XCTestCase {
    override open func setUp() async throws {
        try await super.setUp()
        await TestAssembly.reset()
    }

    override open func tearDown() async throws {
        await TestAssembly.reset()
        try await super.tearDown()
    }
}