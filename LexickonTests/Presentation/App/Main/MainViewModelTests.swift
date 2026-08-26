import XCTest
@testable import Lexickon

@MainActor
final class MainViewModelTests: XCTestCase {
    func testSearchRoutesFrequencyTap() {
        var routedStep: MainStep?
        let viewModel = MainSearchViewModel(
            logoutUseCase: LogoutUseCase(repository: StaticLogoutRepository()),
            navigate: { routedStep = $0 }
        )

        viewModel.frequencyTapped()

        XCTAssertEqual(routedStep, .selectTab(.frequency))
    }

    func testSearchRoutesLogoutAfterSuccessfulLogout() async {
        var routedStep: MainStep?
        let viewModel = MainSearchViewModel(
            logoutUseCase: LogoutUseCase(repository: StaticLogoutRepository()),
            navigate: { routedStep = $0 }
        )

        await viewModel.logoutTapped()

        XCTAssertEqual(routedStep, .logout)
        XCTAssertNil(viewModel.error)
    }

    func testSearchDoesNotRouteLogoutAfterFailedLogout() async {
        var routedStep: MainStep?
        let viewModel = MainSearchViewModel(
            logoutUseCase: LogoutUseCase(
                repository: StaticLogoutRepository(result: .failure(.transport(.offline)))
            ),
            navigate: { routedStep = $0 }
        )

        await viewModel.logoutTapped()

        XCTAssertNil(routedStep)
        XCTAssertEqual(viewModel.error, .transport(.offline))
    }

    func testSearchRoutesSessionExpiredTap() {
        var routedStep: MainStep?
        let viewModel = MainSearchViewModel(
            logoutUseCase: LogoutUseCase(repository: StaticLogoutRepository()),
            navigate: { routedStep = $0 }
        )

        viewModel.sessionExpiredTapped()

        XCTAssertEqual(routedStep, .sessionExpired)
    }

    func testFrequencyRoutesOpenFrequencyTap() {
        var routedStep: MainStep?
        let viewModel = MainFrequencyViewModel { step in
            routedStep = step
        }

        viewModel.openFrequencyTapped()

        XCTAssertEqual(routedStep, .frequency)
    }

    func testProfileRoutesSettingsAndAboutTaps() {
        var routedSteps: [MainStep] = []
        let viewModel = MainProfileViewModel { step in
            routedSteps.append(step)
        }

        viewModel.settingsTapped()
        viewModel.aboutTapped()

        XCTAssertEqual(routedSteps, [.settings, .about])
    }

    func testAboutRoutesCloseTap() {
        var routedStep: MainStep?
        let viewModel = MainAboutViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .aboutDismissed)
    }

    func testOnboardingRoutesCloseTap() {
        var routedStep: MainStep?
        let viewModel = MainOnboardingViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .onboardingDismissed)
    }
}

private actor StaticLogoutRepository: AuthRepository {
    private let result: Result<Void, AppError>

    init(result: Result<Void, AppError> = .success(())) {
        self.result = result
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        throw AppError.unexpected(.dependencyNotConfigured(.authRepository))
    }

    func logout() async throws {
        try result.get()
    }

    func authenticationState() async throws -> AuthenticationState {
        .signedOut
    }
}
