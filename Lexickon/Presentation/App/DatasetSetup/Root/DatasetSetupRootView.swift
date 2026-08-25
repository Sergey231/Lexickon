import SwiftUI

@MainActor
struct DatasetSetupRootView: View {
    @State private var viewModel: DatasetSetupRootViewModel

    init(navigate: @escaping @MainActor (DatasetSetupStep) -> Void) {
        _viewModel = State(initialValue: DatasetSetupRootViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "square.stack.3d.up",
            accessibilityIdentifier: "datasetSetup.placeholder"
        ) {
            Button("navigation.dataset.complete") {
                viewModel.completeTapped()
            }
            .accessibilityIdentifier("datasetSetup.complete")

            Button("navigation.dataset.selection") {
                viewModel.selectionTapped()
            }
            .buttonStyle(.bordered)

            Button("navigation.dataset.storage") {
                viewModel.storageTapped()
            }
            .buttonStyle(.bordered)
        }
    }
}
