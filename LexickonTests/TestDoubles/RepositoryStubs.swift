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

actor DatasetRepositoryStub: DatasetRepository {
    private let catalogResult: Result<[Dataset], AppError>
    private let syncResult: Result<DatasetSyncResult, AppError>

    private(set) var catalogCallCount = 0
    private(set) var syncRequests: [DatasetSyncRequest] = []

    init(
        catalogResult: Result<[Dataset], AppError>,
        syncResult: Result<DatasetSyncResult, AppError>
    ) {
        self.catalogResult = catalogResult
        self.syncResult = syncResult
    }

    func catalog() async throws -> [Dataset] {
        catalogCallCount += 1
        return try catalogResult.get()
    }

    func synchronize(_ request: DatasetSyncRequest) async throws -> DatasetSyncResult {
        syncRequests.append(request)
        return try syncResult.get()
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
