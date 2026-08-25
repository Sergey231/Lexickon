import SwiftUI

@MainActor
struct AuthRootView: View {
    @State private var viewModel: AuthRootViewModel

    init(navigate: @escaping @MainActor (AuthStep) -> Void) {
        _viewModel = State(initialValue: AuthRootViewModel(navigate: navigate))
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.key")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Welcome to Lexickon")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("auth.placeholder")

            Text("Sign in or create an account to continue.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button("Log in") {
                    viewModel.loginTapped()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("auth.login")

                Button("Create account") {
                    viewModel.registrationTapped()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("auth.registration")

                Button("Help") {
                    viewModel.helpTapped()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("auth.help")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
