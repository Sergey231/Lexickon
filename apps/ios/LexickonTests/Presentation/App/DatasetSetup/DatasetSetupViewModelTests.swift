import XCTest
@testable import Lexickon

@MainActor
final class DatasetSetupViewModelTests: XCTestCase {
    func testRootRoutesPrimaryActions() {
        var routedSteps: [DatasetSetupStep] = []
        let viewModel = DatasetSetupRootViewModel { step in
            routedSteps.append(step)
        }

        viewModel.completeTapped()
        viewModel.selectionTapped()
        viewModel.storageTapped()

        XCTAssertEqual(routedSteps, [.main, .selection, .storageInfo])
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
        var routedStep: DatasetSetupStep?
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

        XCTAssertEqual(routedStep, .root)
    }

    func testInstallationDetailsRoutesCloseTap() {
        var routedStep: DatasetSetupStep?
        let viewModel = DatasetInstallationDetailsViewModel { step in
            routedStep = step
        }

        viewModel.closeTapped()

        XCTAssertEqual(routedStep, .root)
    }
}
