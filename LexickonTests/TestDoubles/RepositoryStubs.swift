@testable import Lexickon

actor AuthRepositoryStub: AuthRepository {
    private let registrationResult: Result<User, AppError>
    private let loginResult: Result<AuthenticationState, AppError>
    private let logoutResult: Result<Void, AppError>
    private let stateResult: Result<AuthenticationState, AppError>

    private(set) var registrationRequests: [RegistrationRequest] = []
    private(set) var loginRequests: [LoginRequest] = []
    private(set) var logoutCallCount = 0
    private(set) var stateCallCount = 0

    init(
        registrationResult: Result<User, AppError>,
        loginResult: Result<AuthenticationState, AppError>,
        logoutResult: Result<Void, AppError>,
        stateResult: Result<AuthenticationState, AppError>
    ) {
        self.registrationResult = registrationResult
        self.loginResult = loginResult
        self.logoutResult = logoutResult
        self.stateResult = stateResult
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        registrationRequests.append(request)
        return try registrationResult.get()
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        loginRequests.append(request)
        return try loginResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
        try logoutResult.get()
    }

    func authenticationState() async throws -> AuthenticationState {
        stateCallCount += 1
        return try stateResult.get()
    }
}

actor UserRepositoryStub: UserRepository {
    private let currentUserResult: Result<User, AppError>
    private let settingsResult: Result<UserSettings, AppError>

    private(set) var currentUserCallCount = 0
    private(set) var settingsPatches: [UserSettingsPatch] = []

    init(
        currentUserResult: Result<User, AppError>,
        settingsResult: Result<UserSettings, AppError>
    ) {
        self.currentUserResult = currentUserResult
        self.settingsResult = settingsResult
    }

    func currentUser() async throws -> User {
        currentUserCallCount += 1
        return try currentUserResult.get()
    }

    func updateSettings(_ patch: UserSettingsPatch) async throws -> UserSettings {
        settingsPatches.append(patch)
        return try settingsResult.get()
    }
}

struct DatasetAvailabilityRequest: Equatable, Sendable {
    let installed: [InstalledDataset]
    let wanted: [WantedDataset]
}

actor DatasetCatalogRepositoryStub: DatasetCatalogRepository {
    private let catalogResult: Result<DatasetManifest, AppError>
    private let availabilityResult: Result<DatasetSyncAvailability, AppError>
    private let downloadURLResult: Result<DatasetDownloadURL, AppError>

    private(set) var catalogCallCount = 0
    private(set) var availabilityRequests: [DatasetAvailabilityRequest] = []
    private(set) var downloadURLRequests: [DatasetVersionID] = []

    init(
        catalogResult: Result<DatasetManifest, AppError>,
        availabilityResult: Result<DatasetSyncAvailability, AppError>,
        downloadURLResult: Result<DatasetDownloadURL, AppError> = .failure(.dataset(.unavailable))
    ) {
        self.catalogResult = catalogResult
        self.availabilityResult = availabilityResult
        self.downloadURLResult = downloadURLResult
    }

    func catalog() async throws -> DatasetManifest {
        catalogCallCount += 1
        return try catalogResult.get()
    }

    func availability(
        installed: [InstalledDataset],
        wanted: [WantedDataset]
    ) async throws -> DatasetSyncAvailability {
        availabilityRequests.append(
            DatasetAvailabilityRequest(installed: installed, wanted: wanted)
        )
        return try availabilityResult.get()
    }

    func downloadURL(for versionID: DatasetVersionID) async throws -> DatasetDownloadURL {
        downloadURLRequests.append(versionID)
        return try downloadURLResult.get()
    }
}

actor InstalledDatasetRepositoryStub: InstalledDatasetRepository {
    private let datasetsResult: Result<[InstalledDataset], AppError>
    private let applyResult: Result<Void, AppError>

    private(set) var datasetsCallCount = 0
    private(set) var appliedPlans: [DatasetSyncPlan] = []

    init(
        datasetsResult: Result<[InstalledDataset], AppError> = .success([]),
        applyResult: Result<Void, AppError> = .success(())
    ) {
        self.datasetsResult = datasetsResult
        self.applyResult = applyResult
    }

    func datasets() async throws -> [InstalledDataset] {
        datasetsCallCount += 1
        return try datasetsResult.get()
    }

    func apply(_ plan: DatasetSyncPlan) async throws {
        appliedPlans.append(plan)
        try applyResult.get()
    }
}

actor FrequencyRepositoryStub: FrequencyRepository {
    private let lookupResult: Result<FrequencyResult?, AppError>

    private(set) var queries: [FrequencyQuery] = []

    init(lookupResult: Result<FrequencyResult?, AppError>) {
        self.lookupResult = lookupResult
    }

    func lookup(_ query: FrequencyQuery) async throws -> FrequencyResult? {
        queries.append(query)
        return try lookupResult.get()
    }
}
