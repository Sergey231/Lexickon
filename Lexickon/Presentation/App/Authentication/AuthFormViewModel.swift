import Foundation
import Observation

enum AuthValidationError: Equatable, Sendable {
    case invalidEmail
    case passwordTooShort
}

enum AuthFormError: Equatable, Sendable {
    case validation(AuthValidationError)
    case application(AppError)
}

enum AuthFormState: Equatable, Sendable {
    case idle
    case loading
    case success
    case error(AuthFormError)
}

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
        guard Self.isValidEmail(normalizedEmail) else {
            state = .error(.validation(.invalidEmail))
            return nil
        }
        guard password.count >= 8 else {
            state = .error(.validation(.passwordTooShort))
            return nil
        }
        return LoginRequest(email: normalizedEmail, password: password)
    }

    static func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, let domain = parts.last else { return false }
        return !parts[0].isEmpty && domain.contains(".") && !domain.hasSuffix(".")
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

@Observable
@MainActor
final class RegistrationViewModel {
    var email = ""
    var password = ""
    private(set) var state: AuthFormState = .idle

    private let register: RegisterUseCase

    init(register: RegisterUseCase) {
        self.register = register
    }

    var isLoading: Bool {
        state == .loading
    }

    func submit() async -> Bool {
        guard state != .loading else { return false }
        guard let request = validatedRequest() else { return false }

        state = .loading
        do {
            _ = try await register(request)
            state = .success
            return true
        } catch let error as AppError {
            state = .error(.application(error))
            return false
        } catch {
            state = .error(.application(.unexpected(.invariantViolation)))
            return false
        }
    }

    private func validatedRequest() -> RegistrationRequest? {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard LoginViewModel.isValidEmail(normalizedEmail) else {
            state = .error(.validation(.invalidEmail))
            return nil
        }
        guard password.count >= 8 else {
            state = .error(.validation(.passwordTooShort))
            return nil
        }
        return RegistrationRequest(email: normalizedEmail, password: password)
    }
}
