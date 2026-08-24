import SwiftUI

struct AuthFormContainer<Content: View>: View {
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

enum AuthField: Hashable {
    case email
    case password
}

struct AuthCredentialsFields: View {
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

struct AuthSubmitLabel: View {
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
