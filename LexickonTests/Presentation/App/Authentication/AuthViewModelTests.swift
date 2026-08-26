import XCTest
@testable import Lexickon

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testAuthRootRoutesLoginTap() {
        var routedStep: AuthStep?
        let viewModel = AuthRootViewModel { step in
            routedStep = step
        }

        viewModel.loginTapped()

        XCTAssertEqual(routedStep, .login)
    }

    func testAuthRootRoutesRegistrationTap() {
        var routedStep: AuthStep?
        let viewModel = AuthRootViewModel { step in
            routedStep = step
        }

        viewModel.registrationTapped()

        XCTAssertEqual(routedStep, .registration)
    }

    func testAuthRootRoutesHelpTap() {
        var routedStep: AuthStep?
        let viewModel = AuthRootViewModel { step in
            routedStep = step
        }

        viewModel.helpTapped()

        XCTAssertEqual(routedStep, .help)
    }

    func testAuthHelpRoutesCloseTap() {
        var routedStep: AuthStep?
        let viewModel = AuthHelpViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .helpDismissed)
    }

    func testAuthPrivacyRoutesCloseTap() {
        var routedStep: AuthStep?
        let viewModel = AuthPrivacyViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .privacyDismissed)
    }

    func testLoginValidationKeepsClientErrorsSeparateFromApplicationErrors() async {
        var routedStep: AuthStep?
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: EmptyAuthRepository()),
            navigate: { routedStep = $0 }
        )
        viewModel.email = "invalid"
        viewModel.password = "password-1"

        await viewModel.submit()

        XCTAssertNil(routedStep)
        XCTAssertEqual(viewModel.state, .error(.validation(.invalidEmail)))
    }

    func testLoginFailureUsesApplicationError() async {
        let repository = StaticAuthRepository(
            loginResult: .failure(.authorization(.invalidCredentials))
        )
        var routedStep: AuthStep?
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            navigate: { routedStep = $0 }
        )
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        await viewModel.submit()

        XCTAssertNil(routedStep)
        XCTAssertEqual(
            viewModel.state,
            .error(.application(.authorization(.invalidCredentials)))
        )
    }

    func testLoginSuccessTransitionsToSuccess() async {
        let repository = StaticAuthRepository(loginResult: .success(.signedIn))
        var routedStep: AuthStep?
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            navigate: { routedStep = $0 }
        )
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        await viewModel.submit()

        XCTAssertEqual(routedStep, .authenticated)
        XCTAssertEqual(viewModel.state, .success)
    }

    func testRepeatedSubmitIsBlockedWhileLoading() async throws {
        let repository = SlowAuthRepository()
        var routedSteps: [AuthStep] = []
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            navigate: { routedSteps.append($0) }
        )
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        let firstSubmit = Task { await viewModel.submit() }
        try await Task.sleep(nanoseconds: 50_000_000)
        await viewModel.submit()
        await repository.completeLogin()
        await firstSubmit.value

        let loginCallCount = await repository.loginCallCount
        XCTAssertEqual(routedSteps, [.authenticated])
        XCTAssertEqual(loginCallCount, 1)
    }

    func testLoginRoutesRegistrationTap() {
        let repository = StaticAuthRepository(loginResult: .success(.signedIn))
        var routedStep: AuthStep?
        let viewModel = LoginViewModel(
            loginUseCase: LoginUseCase(repository: repository),
            navigate: { routedStep = $0 }
        )

        viewModel.registrationTapped()

        XCTAssertEqual(routedStep, .registration)
    }

    func testRegistrationSuccessReturnsToCallerWithoutSigningIn() async {
        let repository = StaticAuthRepository(registrationResult: .success(Self.user))
        var routedStep: AuthStep?
        let viewModel = RegistrationViewModel(
            registerUseCase: RegisterUseCase(repository: repository),
            navigate: { routedStep = $0 }
        )
        viewModel.email = "reader@example.com"
        viewModel.password = "password-1"

        await viewModel.submit()

        XCTAssertEqual(routedStep, .registrationCompleted)
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
