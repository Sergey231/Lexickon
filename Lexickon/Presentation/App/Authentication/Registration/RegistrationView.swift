import SwiftUI

@MainActor
struct RegistrationView: View {
    @State private var viewModel: RegistrationViewModel
    @FocusState private var focusedField: AuthField?
    let onRegistered: () -> Void

    init(
        register: RegisterUseCase,
        onRegistered: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: RegistrationViewModel(register: register)
        )
        self.onRegistered = onRegistered
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
                    if await viewModel.submit() {
                        onRegistered()
                    }
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
