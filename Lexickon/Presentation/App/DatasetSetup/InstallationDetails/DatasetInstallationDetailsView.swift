import SwiftUI

@MainActor
struct DatasetInstallationDetailsView: View {
    @State private var viewModel: DatasetInstallationDetailsViewModel

    init(viewModel: DatasetInstallationDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
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
