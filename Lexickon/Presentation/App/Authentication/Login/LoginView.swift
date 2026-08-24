import SwiftUI

@MainActor
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @FocusState private var focusedField: AuthField?
    let onAuthenticated: () -> Void
    let onRegistration: () -> Void

    init(
        login: LoginUseCase,
        onAuthenticated: @escaping () -> Void,
        onRegistration: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: LoginViewModel(login: login))
        self.onAuthenticated = onAuthenticated
        self.onRegistration = onRegistration
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
                    if await viewModel.submit() {
                        onAuthenticated()
                    }
                }
            } label: {
                AuthSubmitLabel(title: "Log in", isLoading: viewModel.isLoading)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("auth.login.submit")

            Button("Create account") {
                onRegistration()
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("auth.login.registration")
        }
        .navigationTitle("Log in")
    }
}
