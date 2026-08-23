import XCTest
@testable import Lexickon

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testLoginValidationKeepsClientErrorsSeparateFromApplicationErrors() async {
        let viewModel = LoginViewModel(login: LoginUseCase(repository: EmptyAuthRepository()))
        viewModel.email = "invalid"
        viewModel.password = "password-1"

        let didSubmit = await viewModel.submit()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(viewModel.state, .error(.validation(.invalidEmail)))
    }

    func testLoginFailureUsesApplicationError() async {
        let repository = StaticAuthRepository(
            loginResult: .failure(.authorization(.invalidCredentials))
        )
        let viewModel = LoginViewModel(login: LoginUseCase(repository: repository))
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        let didSubmit = await viewModel.submit()

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(
            viewModel.state,
            .error(.application(.authorization(.invalidCredentials)))
        )
    }

    func testLoginSuccessTransitionsToSuccess() async {
        let repository = StaticAuthRepository(loginResult: .success(.signedIn))
        let viewModel = LoginViewModel(login: LoginUseCase(repository: repository))
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        let didSubmit = await viewModel.submit()

        XCTAssertTrue(didSubmit)
        XCTAssertEqual(viewModel.state, .success)
    }

    func testRepeatedSubmitIsBlockedWhileLoading() async throws {
        let repository = SlowAuthRepository()
        let viewModel = LoginViewModel(login: LoginUseCase(repository: repository))
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        let firstSubmit = Task { await viewModel.submit() }
        try await Task.sleep(nanoseconds: 50_000_000)
        let secondSubmit = await viewModel.submit()
        await repository.completeLogin()
        let firstResult = await firstSubmit.value

        let loginCallCount = await repository.loginCallCount
        XCTAssertFalse(secondSubmit)
        XCTAssertTrue(firstResult)
        XCTAssertEqual(loginCallCount, 1)
    }

    func testRegistrationSuccessReturnsToCallerWithoutSigningIn() async {
        let repository = StaticAuthRepository(registrationResult: .success(Self.user))
        let viewModel = RegistrationViewModel(
            register: RegisterUseCase(repository: repository)
        )
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        let didSubmit = await viewModel.submit()

        XCTAssertTrue(didSubmit)
        XCTAssertEqual(viewModel.state, .success)
    }

    private static let user = User(
        id: UserID(rawValue: "user-1"),
        email: "reader@example.com",
        settings: UserSettings(
            preferredLanguage: LanguageCode(rawValue: "en"),
            selectedDomains: [],
            offlineMode: false,
            syncOverCellular: false
        )
    )
}

private actor EmptyAuthRepository: AuthRepository {
    func register(_ request: RegistrationRequest) async throws -> User {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func logout() async throws {}

    func authenticationState() async throws -> AuthenticationState {
        .signedOut
    }
}

private actor StaticAuthRepository: AuthRepository {
    private let registrationResult: Result<User, AppError>
    private let loginResult: Result<AuthenticationState, AppError>

    init(
        registrationResult: Result<User, AppError> = .failure(.unexpected(.invariantViolation)),
        loginResult: Result<AuthenticationState, AppError> = .failure(.unexpected(.invariantViolation))
    ) {
        self.registrationResult = registrationResult
        self.loginResult = loginResult
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        try registrationResult.get()
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        try loginResult.get()
    }

    func logout() async throws {}

    func authenticationState() async throws -> AuthenticationState {
        .signedOut
    }
}

private actor SlowAuthRepository: AuthRepository {
    private(set) var loginCallCount = 0
    private var continuation: CheckedContinuation<AuthenticationState, Error>?

    func register(_ request: RegistrationRequest) async throws -> User {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        loginCallCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func logout() async throws {}

    func authenticationState() async throws -> AuthenticationState {
        .signedOut
    }

    func completeLogin() {
        continuation?.resume(returning: .signedIn)
        continuation = nil
    }
}
