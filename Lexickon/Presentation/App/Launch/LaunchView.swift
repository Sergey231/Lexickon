import SwiftUI

@MainActor
struct LaunchView: View {
    @State private var viewModel: LaunchViewModel

    init(viewModel: LaunchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Launch")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("launch.title")

            if viewModel.isLoading {
                ProgressView()
                    .accessibilityIdentifier("launch.progress")
            }

            LaunchErrorText(state: viewModel.state)

            if case .error = viewModel.state {
                VStack(spacing: 12) {
                    Button("Try again") {
                        Task {
                            await viewModel.resolveDestination()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("launch.retry")

                    Button("Log in") {
                        viewModel.loginTapped()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("launch.login")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .task {
            await viewModel.resolveDestination()
        }
    }
}

private struct LaunchErrorText: View {
    let state: LaunchState

    var body: some View {
        if let message = message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("launch.error")
        }
    }

    private var message: String? {
        guard case let .error(error) = state else { return nil }
        switch error {
        case .transport(.offline):
            return "No internet connection."
        case .transport(.timedOut):
            return "The request timed out."
        case .localStorage:
            return "Unable to restore your session."
        case .cancelled:
            return nil
        default:
            return "Something went wrong. Please try again."
        }
    }
}
