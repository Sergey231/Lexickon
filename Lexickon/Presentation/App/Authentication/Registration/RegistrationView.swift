import SwiftUI

@MainActor
struct RegistrationView: View {
    @State private var viewModel: RegistrationViewModel
    @FocusState private var focusedField: AuthField?

    init(viewModel: RegistrationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AuthFormContainer(
            title: "Create account",
            subtitle: "Registration returns you to login for the current backend contract.",
            systemImage: "person.badge.plus",
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
                AuthSubmitLabel(title: "Create account", isLoading: viewModel.isLoading)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("auth.registration.submit")
        }
        .navigationTitle("Create account")
    }
}
