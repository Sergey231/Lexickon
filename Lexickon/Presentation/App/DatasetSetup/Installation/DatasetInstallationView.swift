import SwiftUI

@MainActor
struct DatasetInstallationView: View {
    @State private var viewModel: DatasetInstallationViewModel

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        _viewModel = State(initialValue: DatasetInstallationViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.installation.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "arrow.down.circle",
            accessibilityIdentifier: "datasetSetup.installation.title"
        ) {
            Button("navigation.dataset.complete") {
                viewModel.completeTapped()
            }
        }
    }
}
