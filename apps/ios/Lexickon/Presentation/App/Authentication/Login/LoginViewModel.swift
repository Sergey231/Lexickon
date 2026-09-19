import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    var email: String
    var password: String
    private(set) var state: AuthFormState = .idle

    private let loginUseCase: LoginUseCase
    @ObservationIgnored private let navigate: @MainActor (AuthStep) -> Void

    init(
        loginUseCase: LoginUseCase,
        navigate: @escaping @MainActor (AuthStep) -> Void
    ) {
        self.loginUseCase = loginUseCase
        self.navigate = navigate
        #if DEBUG
        if DebugLoginCredentials.shouldPrefill {
            email = DebugLoginCredentials.email
            password = DebugLoginCredentials.password
        } else {
            email = ""
            password = ""
        }
        #else
        email = ""
        password = ""
        #endif
    }

    var isLoading: Bool {
        state == .loading
    }

    func submit() async {
        guard state != .loading else { return }
        guard let request = validatedRequest() else { return }

        state = .loading
        do {
            let result = try await loginUseCase(request)

            if result == .signedIn {
                state = .success
                navigate(.datasetSetup)
            } else {
                state = .error(.application(.authorization(.unauthenticated)))
            }
        } catch let error as AppError {
            state = .error(.application(error))
        } catch {
            state = .error(.application(.unexpected(.invariantViolation)))
        }
    }

    func registrationTapped() {
        navigate(.registration)
    }

    private func validatedRequest() -> LoginRequest? {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard AuthEmailValidator.isValidEmail(normalizedEmail) else {
            state = .error(.validation(.invalidEmail))
            return nil
        }
        guard password.count >= 8 else {
            state = .error(.validation(.passwordTooShort))
            return nil
        }
        return LoginRequest(email: normalizedEmail, password: password)
    }
}

#if DEBUG
private enum DebugLoginCredentials {
    static let email = "dev@example.com"
    static let password = "password123"

    static var shouldPrefill: Bool {
        !ProcessInfo.processInfo.arguments.contains("--uitest-auth-repository")
    }
}
#endif
