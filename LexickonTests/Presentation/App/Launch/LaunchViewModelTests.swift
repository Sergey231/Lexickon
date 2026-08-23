import XCTest
@testable import Lexickon

@MainActor
final class LaunchViewModelTests: XCTestCase {
    func testSignedInSessionResolvesToMain() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .success(.signedIn)
        )
        let viewModel = LaunchViewModel(
            resolveDestination: ResolveLaunchDestinationUseCase(
                repository: repository
            )
        )

        let destination = await viewModel.resolveDestination()

        XCTAssertEqual(destination, .main)
        XCTAssertEqual(viewModel.state, .resolved(.main))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
    }

    func testSignedOutSessionResolvesToLogin() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .success(.signedOut)
        )
        let viewModel = LaunchViewModel(
            resolveDestination: ResolveLaunchDestinationUseCase(
                repository: repository
            )
        )

        let destination = await viewModel.resolveDestination()

        XCTAssertEqual(destination, .login)
        XCTAssertEqual(viewModel.state, .resolved(.login))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
    }

    func testResolutionErrorStaysOnLaunch() async throws {
        let repository = LaunchAuthRepository(
            stateResult: .failure(.transport(.offline))
        )
        let viewModel = LaunchViewModel(
            resolveDestination: ResolveLaunchDestinationUseCase(
                repository: repository
            )
        )

        let destination = await viewModel.resolveDestination()

        XCTAssertNil(destination)
        XCTAssertEqual(viewModel.state, .error(.transport(.offline)))
        let stateCallCount = await repository.authenticationStateCallCount()
        XCTAssertEqual(stateCallCount, 1)
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
