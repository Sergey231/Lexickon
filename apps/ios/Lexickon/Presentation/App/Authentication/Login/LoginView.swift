import SwiftUI

@MainActor
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @FocusState private var focusedField: AuthField?

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AuthFormContainer(
            title: "Log in",
            subtitle: "Use your email and password.",
            systemImage: "key",
            state: viewModel.state
        ) {
            AuthCredentialsFields(
                email: $viewModel.email,
                password: $viewModel.password,
                focusedField: $focusedField
            )

            Button {
                Task {
                    focusedField = nil
                    await viewModel.submit()
                }
            } label: {
                AuthSubmitLabel(title: "Log in", isLoading: viewModel.isLoading)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("auth.login.submit")

            Button("Create account") {
                viewModel.registrationTapped()
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("auth.login.registration")
        }
        .navigationTitle("Log in")
    }
}
