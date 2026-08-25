import SwiftUI

@MainActor
struct MainFrequencyView: View {
    @State private var viewModel: MainFrequencyViewModel

    init(navigate: @escaping @MainActor (MainStep) -> Void) {
        _viewModel = State(initialValue: MainFrequencyViewModel(navigate: navigate))
    }

    var body: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.frequency.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "chart.bar",
            accessibilityIdentifier: "main.frequency.title"
        ) {
            Button("navigation.main.openFrequency") {
                viewModel.openFrequencyTapped()
            }
        }
    }
}
