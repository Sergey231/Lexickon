import Foundation
import Observation

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
        guard AuthEmailValidator.isValidEmail(normalizedEmail) else {
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
