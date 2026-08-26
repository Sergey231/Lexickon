import SwiftUI

@MainActor
struct DatasetSelectionView: View {
    @State private var viewModel: DatasetSelectionViewModel

    init(viewModel: DatasetSelectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.dataset.selection.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "checklist",
            accessibilityIdentifier: "datasetSetup.selection.title"
        ) {
            Button("navigation.dataset.install") {
                viewModel.installTapped()
            }
        }
    }
}
