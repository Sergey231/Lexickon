import SwiftUI

@MainActor
struct DatasetStorageInfoView: View {
    @State private var viewModel: DatasetStorageInfoViewModel

    init(viewModel: DatasetStorageInfoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.storage.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "internaldrive",
            accessibilityIdentifier: "datasetSetup.storage.title"
        ) {
            Button("navigation.close") {
                viewModel.closeTapped()
            }
        }
    }
}
