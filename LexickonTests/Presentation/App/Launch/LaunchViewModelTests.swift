import XCTest
@testable import Lexickon

@MainActor
final class LaunchViewModelTests: XCTestCase {
    func testSignedInSessionResolvesToMain() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .success(.signedIn)
        )
        var routedStep: AppStep?
        let viewModel = LaunchViewModel(
            resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase(
                repository: repository
            ),
            navigate: { routedStep = $0 }
        )

        await viewModel.resolveDestination()

        XCTAssertEqual(routedStep, .launchCompleted(.main))
        XCTAssertEqual(viewModel.state, .resolved(.main))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
    }

    func testSignedOutSessionResolvesToLogin() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .success(.signedOut)
        )
        var routedStep: AppStep?
        let viewModel = LaunchViewModel(
            resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase(
                repository: repository
            ),
            navigate: { routedStep = $0 }
        )

        await viewModel.resolveDestination()

        XCTAssertEqual(routedStep, .launchCompleted(.login))
        XCTAssertEqual(viewModel.state, .resolved(.login))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
    }

    func testResolutionErrorStaysOnLaunch() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .failure(.transport(.offline))
        )
        var routedStep: AppStep?
        let viewModel = LaunchViewModel(
            resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase(
                repository: repository
            ),
            navigate: { routedStep = $0 }
        )

        await viewModel.resolveDestination()

        XCTAssertNil(routedStep)
        XCTAssertEqual(viewModel.state, .error(.transport(.offline)))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
    }

    func testLoginTapRoutesToLogin() {
        var routedStep: AppStep?
        let viewModel = LaunchViewModel(
            resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase(
                repository: LaunchAuthRepository(stateResult: .success(.signedOut))
            ),
            navigate: { routedStep = $0 }
        )

        viewModel.loginTapped()

        XCTAssertEqual(routedStep, .launchCompleted(.login))
    }
}

private actor LaunchAuthRepository: AuthRepository {
    private let stateResult: Result<AuthenticationState, AppError>

    private(set) var stateCallCount = 0

    init(stateResult: Result<AuthenticationState, AppError>) {
        self.stateResult = stateResult
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func logout() async throws {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func authenticationState() async throws -> AuthenticationState {
        stateCallCount += 1
        return try stateResult.get()
    }

    func authenticationStateCallCount() -> Int {
        stateCallCount
    }
}
