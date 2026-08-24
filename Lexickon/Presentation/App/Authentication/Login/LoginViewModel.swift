import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    var email: String
    var password: String
    private(set) var state: AuthFormState = .idle

    private let login: LoginUseCase

    init(login: LoginUseCase) {
        self.login = login
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

    func submit() async -> Bool {
        guard state != .loading else { return false }
        guard let request = validatedRequest() else { return false }

        state = .loading
        do {
            let result = try await login(request)

            state = result == .signedIn
                ? .success
                : .error(.application(.authorization(.unauthenticated)))

            return result == .signedIn
        } catch let error as AppError {
            state = .error(.application(error))
            return false
        } catch {
            state = .error(.application(.unexpected(.invariantViolation)))
            return false
        }
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
