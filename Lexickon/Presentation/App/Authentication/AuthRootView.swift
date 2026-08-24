import SwiftUI

@MainActor
struct AuthRootView: View {
    let onLogin: () -> Void
    let onRegistration: () -> Void
    let onHelp: () -> Void

    init(
        onLogin: @escaping () -> Void,
        onRegistration: @escaping () -> Void,
        onHelp: @escaping () -> Void
    ) {
        self.onLogin = onLogin
        self.onRegistration = onRegistration
        self.onHelp = onHelp
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
                    onLogin()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("auth.login")

                Button("Create account") {
                    onRegistration()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("auth.registration")

                Button("Help") {
                    onHelp()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("auth.help")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
