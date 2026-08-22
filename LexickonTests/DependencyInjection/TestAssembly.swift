import Foundation
@testable import Lexickon

struct TestAppGraph {
    let container: AppContainer
    let authRepository: AuthRepositoryStub
    let userRepository: UserRepositoryStub
    let datasetRepository: DatasetRepositoryStub
    let frequencyRepository: FrequencyRepositoryStub
}

@MainActor
enum TestAssembly {
    static func makeGraph(
        authRepository: AuthRepositoryStub,
        userRepository: UserRepositoryStub,
        datasetRepository: DatasetRepositoryStub,
        frequencyRepository: FrequencyRepositoryStub
    ) -> TestAppGraph {
        let tokenStore = InMemoryTokenStore()
        let session = SessionController(tokenStore: tokenStore)
        let container = AppContainer(
            repositories: AppRepositories(
                auth: authRepository,
                user: userRepository,
                dataset: datasetRepository,
                frequency: frequencyRepository
            ),
            infrastructure: AppInfrastructure(
                apiClient: APIClient(
                    baseURL: URL(string: "https://unit.test")!,
                    transport: URLSessionTransport(),
                    session: session
                ),
                session: session,
                sessionRefresher: RefreshNotConfigured()
            )
        )

        return TestAppGraph(
            container: container,
            authRepository: authRepository,
            userRepository: userRepository,
            datasetRepository: datasetRepository,
            frequencyRepository: frequencyRepository
        )
    }
}
