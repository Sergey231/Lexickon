import XCTest
@testable import Lexickon

@MainActor
final class DatasetSetupViewModelTests: XCTestCase {
    func testRootRoutesPrimaryActions() {
        var routedSteps: [DatasetSetupStep] = []
        var routedAppStep: AppStep?
        let viewModel = DatasetSetupRootViewModel(
            navigate: { step in routedSteps.append(step) },
            navigateToAppStep: { routedAppStep = $0 }
        )

        viewModel.completeTapped()
        viewModel.selectionTapped()
        viewModel.storageTapped()

        XCTAssertEqual(routedAppStep, .main)
        XCTAssertEqual(routedSteps, [.selection, .storageInfo])
    }

    func testSelectionRoutesInstallTap() {
        var routedStep: DatasetSetupStep?
        let viewModel = DatasetSelectionViewModel { step in
            routedStep = step
        }

        viewModel.installTapped()

        XCTAssertEqual(routedStep, .installation)
    }

    func testInstallationRoutesCompleteTap() {
        var routedStep: AppStep?
        let viewModel = DatasetInstallationViewModel { step in
            routedStep = step
        }

        viewModel.completeTapped()

        XCTAssertEqual(routedStep, .main)
    }

    func testStorageInfoRoutesCloseTap() {
        var routedStep: DatasetSetupStep?
        let viewModel = DatasetStorageInfoViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .storageInfoDismissed)
    }

    func testInstallationDetailsRoutesCloseTap() {
        var routedStep: DatasetSetupStep?
        let viewModel = DatasetInstallationDetailsViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .installationDetailsDismissed)
    }
}
