import XCTest
@testable import Lexickon

@MainActor
final class AppContainerTests: XCTestCase {
    func testTestAssemblyRoutesUseCasesToEveryInjectedRepository() async throws {
        var fixture = Fixture()
        let graph = TestAssembly.makeGraph(
            authRepository: fixture.authRepository,
            userRepository: fixture.userRepository,
            datasetRepository: fixture.datasetRepository,
            frequencyRepository: fixture.frequencyRepository
        )
        let useCases = graph.container.useCases

        let registeredUser = try await useCases.register(
            fixture.registrationRequest
        )
        let authenticationState = try await useCases.login(
            fixture.loginRequest
        )
        try await useCases.logout()
        let restoredState = try await useCases.authenticationState()
        let currentUser = try await useCases.currentUser()
        let updatedSettings = try await useCases.updateUserSettings(
            fixture.settingsPatch
        )
        let datasets = try await useCases.datasetCatalog()
        let syncResult = try await useCases.synchronizeDatasets(
            fixture.syncRequest
        )
        let frequency = try await useCases.lookupFrequency(
            fixture.frequencyQuery
        )

        XCTAssertEqual(registeredUser, fixture.user)
        XCTAssertEqual(authenticationState, .signedIn)
        XCTAssertEqual(restoredState, .signedIn)
        XCTAssertEqual(currentUser, fixture.user)
        XCTAssertEqual(updatedSettings, fixture.updatedSettings)
        XCTAssertEqual(datasets, [fixture.dataset])
        XCTAssertEqual(syncResult, fixture.syncResult)
        XCTAssertEqual(frequency, fixture.frequencyResult)

        let registrationRequests = await graph.authRepository.registrationRequests
        let loginRequests = await graph.authRepository.loginRequests
        let logoutCallCount = await graph.authRepository.logoutCallCount
        let stateCallCount = await graph.authRepository.stateCallCount
        let currentUserCallCount = await graph.userRepository.currentUserCallCount
        let settingsPatches = await graph.userRepository.settingsPatches
        let catalogCallCount = await graph.datasetRepository.catalogCallCount
        let syncRequests = await graph.datasetRepository.syncRequests
        let frequencyQueries = await graph.frequencyRepository.queries

        XCTAssertEqual(registrationRequests, [fixture.registrationRequest])
        XCTAssertEqual(loginRequests, [fixture.loginRequest])
        XCTAssertEqual(logoutCallCount, 1)
        XCTAssertEqual(stateCallCount, 1)
        XCTAssertEqual(currentUserCallCount, 1)
        XCTAssertEqual(settingsPatches, [fixture.settingsPatch])
        XCTAssertEqual(catalogCallCount, 1)
        XCTAssertEqual(syncRequests, [fixture.syncRequest])
        XCTAssertEqual(frequencyQueries, [fixture.frequencyQuery])
    }

    func testProductionAssemblyUsesRemoteAuthAdapter() async throws {
        let container = ProductionAssembly.makeContainer()

        let state = try await container.useCases.authenticationState()

        XCTAssertEqual(state, .signedOut)
    }
}

private struct Fixture {
    let settings = UserSettings(
        preferredLanguage: LanguageCode(rawValue: "en"),
        selectedDomains: [DatasetDomain(rawValue: "core")],
        offlineMode: false,
        syncOverCellular: false
    )

    lazy var updatedSettings = UserSettings(
        preferredLanguage: settings.preferredLanguage,
        selectedDomains: settings.selectedDomains,
        offlineMode: true,
        syncOverCellular: settings.syncOverCellular
    )

    lazy var user = User(
        id: UserID(rawValue: "user-1"),
        email: "reader@example.com",
        settings: settings
    )

    let registrationRequest = RegistrationRequest(
        email: "reader@example.com",
        password: "not-a-real-secret"
    )

    let loginRequest = LoginRequest(
        email: "reader@example.com",
        password: "not-a-real-secret"
    )

    lazy var settingsPatch = UserSettingsPatch(
        offlineMode: true
    )

    let dataset = Dataset(
        key: DatasetKey(rawValue: "core-en"),
        language: LanguageCode(rawValue: "en"),
        domain: DatasetDomain(rawValue: "core"),
        title: "Core English",
        latestVersion: DatasetVersion(rawValue: "1.0.0"),
        latestVersionID: DatasetVersionID(rawValue: "version-1"),
        sqliteSchemaVersion: 1,
        compression: .gzip,
        compressedSizeBytes: 18_400_000,
        checksumSHA256: String(repeating: "a", count: 64),
        requiredPlan: AccessPlan(rawValue: "free"),
        status: .active
    )

    let syncRequest = DatasetSyncRequest(
        clientSchemaVersion: 1,
        installed: [],
        wanted: [
            WantedDataset(
                language: LanguageCode(rawValue: "en"),
                domain: DatasetDomain(rawValue: "core")
            )
        ]
    )

    lazy var syncResult = DatasetSyncResult(
        schemaVersion: 1,
        actions: [
            DatasetSyncAction(
                key: dataset.key,
                status: .missing,
                installedVersion: nil,
                latestVersion: dataset.latestVersion
            )
        ]
    )

    let frequencyQuery = FrequencyQuery(
        text: "example",
        datasetKey: DatasetKey(rawValue: "core-en")
    )

    lazy var frequencyResult = FrequencyResult(
        query: frequencyQuery,
        matchedText: "example",
        measurement: FrequencyMeasurement(
            metricIdentifier: "test-only",
            value: 42
        )
    )

    lazy var authRepository = AuthRepositoryStub(
        registrationResult: .success(user),
        loginResult: .success(.signedIn),
        logoutResult: .success(()),
        stateResult: .success(.signedIn)
    )

    lazy var userRepository = UserRepositoryStub(
        currentUserResult: .success(user),
        settingsResult: .success(updatedSettings)
    )

    lazy var datasetRepository = DatasetRepositoryStub(
        catalogResult: .success([dataset]),
        syncResult: .success(syncResult)
    )

    lazy var frequencyRepository = FrequencyRepositoryStub(
        lookupResult: .success(frequencyResult)
    )
}
