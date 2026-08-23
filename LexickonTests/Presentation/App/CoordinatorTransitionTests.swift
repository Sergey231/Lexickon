import XCTest
@testable import Lexickon

@MainActor
final class CoordinatorTransitionTests: XCTestCase {
    func testAuthCoordinatorTransitionTableAndPresentations() {
        var emittedStep: AppStep?
        let coordinator = AuthCoordinator { emittedStep = $0 }
        let transitions: [(step: AuthStep, expectedPath: [AuthStep])] = [
            (.login, [.login]),
            (.login, [.login]),
            (.registration, [.login, .registration]),
            (.login, [.login]),
            (.registrationCompleted, [.login])
        ]

        for transition in transitions {
            coordinator.navigate(to: transition.step)
            XCTAssertEqual(coordinator.path, transition.expectedPath)
        }

        coordinator.navigate(to: .help)
        coordinator.navigate(to: .privacy)

        XCTAssertEqual(coordinator.sheet, .help)
        XCTAssertEqual(coordinator.fullScreenCover, .privacy)

        coordinator.navigate(to: .authenticated)
        XCTAssertEqual(emittedStep, .authenticated)
    }

    func testDatasetSetupCoordinatorTransitionTableAndPresentations() {
        var emittedStep: AppStep?
        let coordinator = DatasetSetupCoordinator { emittedStep = $0 }
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

        coordinator.navigate(to: .completed)
        XCTAssertEqual(emittedStep, .datasetSetupCompleted)
    }

    func testMainCoordinatorTransitionTableAndSelectedTab() {
        var emittedStep: AppStep?
        let coordinator = MainCoordinator { emittedStep = $0 }
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

        coordinator.navigate(to: .logout)
        XCTAssertEqual(emittedStep, .logout)

        coordinator.navigate(to: .sessionExpired)
        XCTAssertEqual(emittedStep, .sessionExpired)
    }

    func testAppCoordinatorNormalizesStepsToPresentationSteps() {
        let coordinator = AppCoordinator()

        XCTAssertEqual(coordinator.currentStep, .authenticationRequired)

        coordinator.navigate(to: .authenticated)
        XCTAssertEqual(coordinator.currentStep, .datasetSetupRequired)

        coordinator.navigate(to: .datasetSetupCompleted)
        XCTAssertEqual(coordinator.currentStep, .mainRequired)

        coordinator.navigate(to: .sessionExpired)
        XCTAssertEqual(coordinator.currentStep, .authenticationRequired)

        coordinator.navigate(to: .mainRequired)
        coordinator.navigate(to: .logout)
        XCTAssertEqual(coordinator.currentStep, .authenticationRequired)
    }
}
