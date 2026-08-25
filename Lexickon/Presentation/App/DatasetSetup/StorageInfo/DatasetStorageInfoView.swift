import SwiftUI

@MainActor
struct DatasetStorageInfoView: View {
    @State private var viewModel: DatasetStorageInfoViewModel

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        _viewModel = State(initialValue: DatasetStorageInfoViewModel(navigate: navigate))
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
