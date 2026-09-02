import XCTest
@testable import Lexickon

@MainActor
final class CoordinatorTransitionTests: XCTestCase {
    func testAuthCoordinatorTransitionTableAndPresentations() {
        var datasetSetupRequestCount = 0
        let coordinator = AuthCoordinator {
            datasetSetupRequestCount += 1
        }
        let transitions: [(step: AuthStep, expectedPath: [AuthStep])] = [
            (.login, [.login]),
            (.login, [.login]),
            (.registration, [.login, .registration]),
            (.login, [.login])
        ]

        for transition in transitions {
            coordinator.navigate(to: transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.navigate(to: .help)
        coordinator.navigate(to: .privacy)

        XCTAssertEqual(coordinator.sheet, .help)
        XCTAssertEqual(coordinator.fullScreenCover, .privacy)

        coordinator.navigate(to: .root)

        XCTAssertEqual(coordinator.path, [])
        XCTAssertNil(coordinator.sheet)
        XCTAssertNil(coordinator.fullScreenCover)

        coordinator.navigate(to: .datasetSetup)
        XCTAssertEqual(datasetSetupRequestCount, 1)
    }

    func testDatasetSetupCoordinatorTransitionTableAndPresentations() {
        let coordinator = DatasetSetupCoordinator()
        let transitions: [(step: DatasetSetupStep, expectedPath: [DatasetSetupStep])] = [
            (.selection, [.selection]),
            (.selection, [.selection]),
            (.installation, [.selection, .installation]),
            (.selection, [.selection])
        ]

        for transition in transitions {
            coordinator.navigate(to: transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.navigate(to: .storageInfo)
        coordinator.navigate(to: .installationDetails)

        XCTAssertEqual(coordinator.sheet, .storageInfo)
        XCTAssertEqual(coordinator.fullScreenCover, .installationDetails)

        coordinator.navigate(to: .storageInfoDismissed)
        coordinator.navigate(to: .installationDetailsDismissed)

        XCTAssertNil(coordinator.sheet)
        XCTAssertNil(coordinator.fullScreenCover)
    }

    func testMainCoordinatorTransitionTableAndSelectedTab() {
        let coordinator = MainCoordinator()
        let transitions: [(step: MainStep, expectedPath: [MainStep])] = [
            (.frequency, [.frequency]),
            (.frequency, [.frequency]),
            (.profile, [.frequency, .profile]),
            (.settings, [.frequency, .profile, .settings]),
            (.profile, [.frequency, .profile])
        ]

        for transition in transitions {
            coordinator.navigate(to: transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.navigate(to: .selectTab(.profile))
        coordinator.navigate(to: .about)
        coordinator.navigate(to: .onboarding)

        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertEqual(coordinator.sheet, .about)
        XCTAssertEqual(coordinator.fullScreenCover, .onboarding)

        coordinator.navigate(to: .aboutDismissed)
        coordinator.navigate(to: .onboardingDismissed)

        XCTAssertNil(coordinator.sheet)
        XCTAssertNil(coordinator.fullScreenCover)
    }

    func testAppCoordinatorNavigatesDirectlyToRequestedStep() {
        let coordinator = AppCoordinator()

        XCTAssertEqual(coordinator.currentStep, .launch)

        for step in [AppStep.authentication, .datasetSetup, .main, .launch] {
            coordinator.navigate(to: step)
            XCTAssertEqual(coordinator.currentStep, step)
        }
    }
}
