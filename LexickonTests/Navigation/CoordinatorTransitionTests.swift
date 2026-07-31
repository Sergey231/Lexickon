import XCTest
@testable import Lexickon

@MainActor
final class CoordinatorTransitionTests: XCTestCase {
    func testAuthCoordinatorTransitionTableAndPresentations() {
        let coordinator = AuthCoordinator { _ in }
        let transitions: [(step: AuthStep, expectedPath: [AuthStep])] = [
            (.login, [.login]),
            (.login, [.login]),
            (.registration, [.login, .registration]),
            (.login, [.login])
        ]

        for transition in transitions {
            coordinator.handle(transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.handle(.help)
        coordinator.handle(.privacy)

        XCTAssertEqual(coordinator.sheet, .help)
        XCTAssertEqual(coordinator.fullScreenCover, .privacy)
    }

    func testDatasetSetupCoordinatorTransitionTableAndPresentations() {
        let coordinator = DatasetSetupCoordinator { _ in }
        let transitions: [(step: DatasetSetupStep, expectedPath: [DatasetSetupStep])] = [
            (.selection, [.selection]),
            (.selection, [.selection]),
            (.installation, [.selection, .installation]),
            (.selection, [.selection])
        ]

        for transition in transitions {
            coordinator.handle(transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.handle(.storageInfo)
        coordinator.handle(.installationDetails)

        XCTAssertEqual(coordinator.sheet, .storageInfo)
        XCTAssertEqual(coordinator.fullScreenCover, .installationDetails)
    }

    func testMainCoordinatorTransitionTableAndSelectedTab() {
        let coordinator = MainCoordinator { _ in }
        let transitions: [(step: MainStep, expectedPath: [MainStep])] = [
            (.frequency, [.frequency]),
            (.frequency, [.frequency]),
            (.profile, [.frequency, .profile]),
            (.settings, [.frequency, .profile, .settings]),
            (.profile, [.frequency, .profile])
        ]

        for transition in transitions {
            coordinator.handle(transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.handle(.selectTab(.profile))
        coordinator.handle(.about)
        coordinator.handle(.onboarding)

        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertEqual(coordinator.sheet, .about)
        XCTAssertEqual(coordinator.fullScreenCover, .onboarding)
    }

    func testAppCoordinatorMapsTypedChildResultsToRootSteps() {
        let coordinator = AppCoordinator()

        XCTAssertEqual(coordinator.root, .authentication)

        coordinator.handle(AuthCoordinatorResult.authenticated)
        XCTAssertEqual(coordinator.root, .datasetSetup)

        coordinator.handle(DatasetSetupCoordinatorResult.completed)
        XCTAssertEqual(coordinator.root, .main)

        coordinator.handle(MainCoordinatorResult.sessionExpired)
        XCTAssertEqual(coordinator.root, .authentication)

        coordinator.handle(.showMain)
        coordinator.handle(MainCoordinatorResult.logout)
        XCTAssertEqual(coordinator.root, .authentication)
    }

    func testRootReplacementReleasesCompletedChildAndClearsItsPath() {
        let coordinator = AppCoordinator()
        weak var releasedAuthCoordinator: AuthCoordinator?

        do {
            let authCoordinator = try XCTUnwrap(coordinator.authCoordinator)
            releasedAuthCoordinator = authCoordinator
            authCoordinator.handle(.login)
            XCTAssertEqual(authCoordinator.path, [.login])

            authCoordinator.finish(with: .authenticated)
        } catch {
            XCTFail("Expected an authentication child coordinator: \(error)")
        }

        XCTAssertNil(releasedAuthCoordinator)
        XCTAssertNil(coordinator.authCoordinator)
        XCTAssertEqual(coordinator.datasetSetupCoordinator?.path, [])
    }

    func testRepeatedRootStepKeepsSingleChildCoordinator() throws {
        let coordinator = AppCoordinator()
        let authCoordinator = try XCTUnwrap(coordinator.authCoordinator)
        let initialRevision = coordinator.rootRevision

        coordinator.handle(.showAuthentication)
        coordinator.handle(.showAuthentication)

        XCTAssertTrue(authCoordinator === coordinator.authCoordinator)
        XCTAssertEqual(coordinator.rootRevision, initialRevision)

        coordinator.handle(.showDatasetSetup)
        let datasetCoordinator = try XCTUnwrap(coordinator.datasetSetupCoordinator)
        let datasetRevision = coordinator.rootRevision

        coordinator.handle(.showDatasetSetup)
        coordinator.handle(.showDatasetSetup)

        XCTAssertTrue(datasetCoordinator === coordinator.datasetSetupCoordinator)
        XCTAssertEqual(coordinator.rootRevision, datasetRevision)
    }
}
