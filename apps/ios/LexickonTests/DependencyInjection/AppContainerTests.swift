import XCTest
@testable import Lexickon

@MainActor
final class AppContainerTests: XCTestCase {
    // The complete graph is exercised together so every injected boundary is verified.
    // swiftlint:disable:next function_body_length
    func testTestAssemblyRoutesUseCasesToEveryInjectedRepository() async throws {
        var fixture = Fixture()
        let graph = TestAssembly.makeGraph(
            authRepository: fixture.authRepository,
            userRepository: fixture.userRepository,
            datasetCatalogRepository: fixture.datasetCatalogRepository,
            installedDatasetRepository: fixture.installedDatasetRepository,
            frequencyRepository: fixture.frequencyRepository
        )
        let useCases = graph.container.useCases

        let registeredUser = try await useCases.registerUseCase(
            fixture.registrationRequest
        )
        let authenticationState = try await useCases.loginUseCase(
            fixture.loginRequest
        )
        try await useCases.logoutUseCase()
        let launchDestination = try await useCases.resolveLaunchDestinationUseCase()
        let currentUser = try await useCases.currentUserUseCase()
        let updatedSettings = try await useCases.updateUserSettingsUseCase(
            fixture.settingsPatch
        )
        let datasets = try await useCases.datasetCatalogUseCase()
        let installedDatasets = try await useCases.installedDatasetsUseCase()
        let syncPlan = try await useCases.synchronizeDatasetsUseCase(
            fixture.syncInput
        )
        let downloadURL = try await useCases.datasetDownloadURLUseCase(
            for: fixture.dataset.latestVersionID
        )
        let frequency = try await useCases.lookupFrequencyUseCase(
            fixture.frequencyQuery
        )

        XCTAssertEqual(registeredUser, fixture.user)
        XCTAssertEqual(authenticationState, .signedIn)
        XCTAssertEqual(launchDestination, .main)
        XCTAssertEqual(currentUser, fixture.user)
        XCTAssertEqual(updatedSettings, fixture.updatedSettings)
        XCTAssertEqual(datasets, fixture.manifest)
        XCTAssertEqual(installedDatasets, [])
        XCTAssertEqual(syncPlan, fixture.syncPlan)
        XCTAssertEqual(downloadURL, fixture.downloadURL)
        XCTAssertEqual(frequency, fixture.frequencyResult)

        let registrationRequests = await graph.authRepository.registrationRequests
        let loginRequests = await graph.authRepository.loginRequests
        let logoutCallCount = await graph.authRepository.logoutCallCount
        let stateCallCount = await graph.authRepository.stateCallCount
        let currentUserCallCount = await graph.userRepository.currentUserCallCount
        let settingsPatches = await graph.userRepository.settingsPatches
        let catalogCallCount = await graph.datasetCatalogRepository.catalogCallCount
        let availabilityRequests = await graph.datasetCatalogRepository.availabilityRequests
        let downloadURLRequests = await graph.datasetCatalogRepository.downloadURLRequests
        let datasetsCallCount = await graph.installedDatasetRepository.datasetsCallCount
        let appliedPlans = await graph.installedDatasetRepository.appliedPlans
        let frequencyQueries = await graph.frequencyRepository.queries

        XCTAssertEqual(registrationRequests, [fixture.registrationRequest])
        XCTAssertEqual(loginRequests, [fixture.loginRequest])
        XCTAssertEqual(logoutCallCount, 1)
        XCTAssertEqual(stateCallCount, 1)
        XCTAssertEqual(currentUserCallCount, 1)
        XCTAssertEqual(settingsPatches, [fixture.settingsPatch])
        XCTAssertEqual(catalogCallCount, 2)
        XCTAssertEqual(
            availabilityRequests,
            [DatasetAvailabilityRequest(installed: [], wanted: fixture.syncInput.wanted)]
        )
        XCTAssertEqual(downloadURLRequests, [fixture.dataset.latestVersionID])
        XCTAssertEqual(datasetsCallCount, 2)
        XCTAssertEqual(appliedPlans, [fixture.syncPlan])
        XCTAssertEqual(frequencyQueries, [fixture.frequencyQuery])
    }

    func testProductionAssemblyUsesRemoteAuthAdapter() async throws {
        let container = ProductionAssembly.makeContainer()

        let launchDestination = try await container.useCases.resolveLaunchDestinationUseCase()

        XCTAssertEqual(launchDestination, .login)
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

    lazy var manifest = DatasetManifest(
        schemaVersion: 1,
        generatedAt: Date(timeIntervalSince1970: 1),
        datasets: [dataset]
    )

    let syncInput = SynchronizeDatasetsInput(
        wanted: [
            WantedDataset(
                language: LanguageCode(rawValue: "en"),
                domain: DatasetDomain(rawValue: "core")
            )
        ]
    )

    lazy var syncAvailability = DatasetSyncAvailability(
        schemaVersion: 1,
        entries: [
            DatasetSyncAvailabilityEntry(
                key: dataset.key,
                status: .missing
            )
        ]
    )

    lazy var syncPlan = DatasetSyncPlan(
        schemaVersion: 1,
        actions: [
            DatasetSyncAction(
                key: dataset.key,
                status: .missing,
                installedVersion: nil,
                latestVersion: dataset.latestVersion,
                latestVersionID: dataset.latestVersionID,
                sqliteSchemaVersion: dataset.sqliteSchemaVersion,
                compressedSizeBytes: dataset.compressedSizeBytes,
                checksumSHA256: dataset.checksumSHA256,
                requiredPlan: dataset.requiredPlan
            )
        ]
    )

    lazy var downloadURL = DatasetDownloadURL(
        url: URL(string: "https://storage.test/core.sqlite.gz")!,
        expiresAt: Date(timeIntervalSince1970: 100),
        checksumSHA256: dataset.checksumSHA256,
        compressedSizeBytes: dataset.compressedSizeBytes,
        compression: dataset.compression
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

    lazy var datasetCatalogRepository = DatasetCatalogRepositoryStub(
        catalogResult: .success(manifest),
        availabilityResult: .success(syncAvailability),
        downloadURLResult: .success(downloadURL)
    )

    lazy var installedDatasetRepository = InstalledDatasetRepositoryStub(
        datasetsResult: .success([])
    )

    lazy var frequencyRepository = FrequencyRepositoryStub(
        lookupResult: .success(frequencyResult)
    )
}
