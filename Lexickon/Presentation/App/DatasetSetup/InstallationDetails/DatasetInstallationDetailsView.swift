import SwiftUI

@MainActor
struct DatasetInstallationDetailsView: View {
    @State private var viewModel: DatasetInstallationDetailsViewModel

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        _viewModel = State(
            initialValue: DatasetInstallationDetailsViewModel(navigate: navigate)
        )
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.installation.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "arrow.down.circle",
            accessibilityIdentifier: "datasetSetup.installationDetails.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
