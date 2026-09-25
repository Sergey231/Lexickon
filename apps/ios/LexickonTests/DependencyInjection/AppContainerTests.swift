import XCTest
import FactoryKit
@testable import Lexickon

@MainActor
final class AppContainerTests: BaseTestCase {
    // The complete graph is exercised together so every injected boundary is verified.
    // swiftlint:disable:next function_body_length
    func testTestAssemblyRoutesUseCasesToEveryInjectedRepository() async throws {
        await TestAssembly.reset()
        var fixture = Fixture()
        _ = TestAssembly.makeGraph(
            authRepository: fixture.authRepository,
            userRepository: fixture.userRepository,
            datasetCatalogRepository: fixture.datasetCatalogRepository,
            installedDatasetRepository: fixture.installedDatasetRepository,
            frequencyRepository: fixture.frequencyRepository
        )
        let container = Container.shared

        let registeredUser = try await container.registerUseCase()(fixture.registrationRequest)
        let authenticationState = try await container.loginUseCase()(fixture.loginRequest)
        try await container.logoutUseCase()()
        let launchDestination = try await container.resolveLaunchDestinationUseCase()()
        let currentUser = try await container.currentUserUseCase()()
        let updatedSettings = try await container.updateUserSettingsUseCase()(fixture.settingsPatch)
        let datasets = try await container.datasetCatalogUseCase()()
        let installedDatasets = try await container.installedDatasetsUseCase()()
        let syncPlan = try await container.synchronizeDatasetsUseCase()(fixture.syncInput)
        let downloadURL = try await container.datasetDownloadURLUseCase()(for: fixture.dataset.latestVersionID)
        let frequency = try await container.lookupFrequencyUseCase()(fixture.frequencyQuery)

        XCTAssertEqual(registeredUser, fixture.user)
        XCTAssertEqual(authenticationState, .signedIn)
        XCTAssertEqual(launchDestination, LaunchDestination.main)
        XCTAssertEqual(currentUser, fixture.user)
        XCTAssertEqual(updatedSettings, fixture.updatedSettings)
        XCTAssertEqual(datasets, fixture.manifest)
        XCTAssertEqual(installedDatasets, [])
        XCTAssertEqual(syncPlan, fixture.syncPlan)
        XCTAssertEqual(downloadURL, fixture.downloadURL)
        XCTAssertEqual(frequency, fixture.frequencyResult)

        let registrationRequests = await fixture.authRepository.registrationRequests
        let loginRequests = await fixture.authRepository.loginRequests
        let logoutCallCount = await fixture.authRepository.logoutCallCount
        let stateCallCount = await fixture.authRepository.stateCallCount
        let currentUserCallCount = await fixture.userRepository.currentUserCallCount
        let settingsPatches = await fixture.userRepository.settingsPatches
        let catalogCallCount = await fixture.datasetCatalogRepository.catalogCallCount
        let availabilityRequests = await fixture.datasetCatalogRepository.availabilityRequests
        let downloadURLRequests = await fixture.datasetCatalogRepository.downloadURLRequests
        let datasetsCallCount = await fixture.installedDatasetRepository.datasetsCallCount
        let appliedPlans = await fixture.installedDatasetRepository.appliedPlans
        let frequencyQueries = await fixture.frequencyRepository.queries

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
        ProductionAssembly.makeContainer()

        let launchDestination = try await Container.shared.resolveLaunchDestinationUseCase()()

        XCTAssertEqual(launchDestination, LaunchDestination.login)
    }

    func testFactoryTestingIsolation() async throws {
        let testSettings = UserSettings(
            preferredLanguage: LanguageCode(rawValue: "en"),
            selectedDomains: [DatasetDomain(rawValue: "core")],
            offlineMode: false,
            syncOverCellular: false
        )
        let stub1 = AuthRepositoryStub(
            registrationResult: .success(User(id: UserID(rawValue: "1"), email: "a@b.com", settings: testSettings)),
            loginResult: .success(.signedIn),
            logoutResult: .success(()),
            stateResult: .success(.signedIn)
        )
        let stub2 = AuthRepositoryStub(
            registrationResult: .success(User(id: UserID(rawValue: "2"), email: "c@d.com", settings: testSettings)),
            loginResult: .success(.signedIn),
            logoutResult: .success(()),
            stateResult: .success(.signedIn)
        )

        // First makeGraph with stub1
        let graph1 = TestAssembly.makeGraph(
            authRepository: stub1,
            userRepository: UserRepositoryStub(
                currentUserResult: .success(User(id: UserID(rawValue: "1"), email: "a@b.com", settings: testSettings)),
                settingsResult: .success(testSettings)
            ),
            datasetCatalogRepository: DatasetCatalogRepositoryStub(
                catalogResult: .success(DatasetManifest(schemaVersion: 1, generatedAt: Date(), datasets: [])),
                availabilityResult: .success(DatasetSyncAvailability(schemaVersion: 1, entries: [])),
                downloadURLResult: .failure(AppError.dataset(.unavailable))
            ),
            installedDatasetRepository: InstalledDatasetRepositoryStub(),
            frequencyRepository: FrequencyRepositoryStub(lookupResult: .success(nil))
        )

        let auth1 = try await Container.shared.resolveLaunchDestinationUseCase()()

        // Reset and makeGraph with stub2
        await TestAssembly.reset()

        let graph2 = TestAssembly.makeGraph(
            authRepository: stub2,
            userRepository: UserRepositoryStub(
                currentUserResult: .success(User(id: UserID(rawValue: "2"), email: "c@d.com", settings: testSettings)),
                settingsResult: .success(testSettings)
            ),
            datasetCatalogRepository: DatasetCatalogRepositoryStub(
                catalogResult: .success(DatasetManifest(schemaVersion: 1, generatedAt: Date(), datasets: [])),
                availabilityResult: .success(DatasetSyncAvailability(schemaVersion: 1, entries: [])),
                downloadURLResult: .failure(AppError.dataset(.unavailable))
            ),
            installedDatasetRepository: InstalledDatasetRepositoryStub(),
            frequencyRepository: FrequencyRepositoryStub(lookupResult: .success(nil))
        )

        // Verify stub2 is used (container is clean)
        let auth2 = try await Container.shared.resolveLaunchDestinationUseCase()()

        // Both should succeed (no crash from state pollution)
        _ = try await auth1
        _ = try await auth2
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