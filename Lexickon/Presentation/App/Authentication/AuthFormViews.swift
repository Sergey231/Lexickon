import Foundation
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

private struct AuthFormContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let state: AuthFormState
    @ViewBuilder let content: Content

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .font(.system(size: 36))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text(title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section {
                content
            }

            Section {
                AuthErrorText(state: state)
            }
        }
    }
}

private enum AuthField: Hashable {
    case email
    case password
}

private struct AuthCredentialsFields: View {
    @Binding var email: String
    @Binding var password: String
    let focusedField: FocusState<AuthField?>.Binding

    var body: some View {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(focusedField, equals: .email)
            .accessibilityIdentifier("auth.email")

        if ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository") {
            TextField("Password", text: $password)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused(focusedField, equals: .password)
                .accessibilityIdentifier("auth.password")
        } else {
            SecureField("Password", text: $password)
                .textContentType(.password)
                .focused(focusedField, equals: .password)
                .accessibilityIdentifier("auth.password")
        }
    }
}

private struct AuthSubmitLabel: View {
    let title: String
    let isLoading: Bool

    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
            }
            Text(title)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AuthErrorText: View {
    let state: AuthFormState

    var body: some View {
        if let message = message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("auth.error")
        }
    }

    private var message: String? {
        guard case let .error(error) = state else { return nil }
        switch error {
        case let .validation(validationError):
            switch validationError {
            case .invalidEmail:
                return "Enter a valid email address."
            case .passwordTooShort:
                return "Password must contain at least 8 characters."
            }
        case let .application(appError):
            switch appError {
            case .authorization(.invalidCredentials):
                return "Email or password is incorrect."
            case .authorization(.accountConflict):
                return "An account with this email already exists."
            case .authorization(.sessionExpired), .authorization(.unauthenticated):
                return "Session expired. Please log in again."
            case .transport(.offline):
                return "No internet connection."
            case .transport(.timedOut):
                return "The request timed out."
            case .cancelled:
                return nil
            default:
                return "Something went wrong. Please try again."
            }
        }
    }
}
