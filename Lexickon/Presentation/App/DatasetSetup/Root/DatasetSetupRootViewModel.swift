import Observation

@Observable
@MainActor
final class DatasetSetupRootViewModel {
    @ObservationIgnored private let navigate: @MainActor (DatasetSetupStep) -> Void
    @ObservationIgnored private let navigateToAppStep: @MainActor (AppStep) -> Void

    init(
        navigate: @escaping @MainActor (DatasetSetupStep) -> Void,
        navigateToAppStep: @escaping @MainActor (AppStep) -> Void
    ) {
        self.navigate = navigate
        self.navigateToAppStep = navigateToAppStep
    }

    func completeTapped() {
        navigateToAppStep(.main)
    }

    func selectionTapped() {
        navigate(.selection)
    }

    func storageTapped() {
        navigate(.storageInfo)
    }
}
