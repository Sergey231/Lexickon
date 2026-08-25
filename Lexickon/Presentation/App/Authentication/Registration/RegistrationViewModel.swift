import Foundation
import Observation

@Observable
@MainActor
final class RegistrationViewModel {
    var email = ""
    var password = ""
    private(set) var state: AuthFormState = .idle

    private let register: RegisterUseCase
    @ObservationIgnored private let navigate: @MainActor (AuthStep) -> Void

    init(
        register: RegisterUseCase,
        navigate: @escaping @MainActor (AuthStep) -> Void
    ) {
        self.register = register
        self.navigate = navigate
    }

    var isLoading: Bool {
        state == .loading
    }

    func submit() async {
        guard state != .loading else { return }
        guard let request = validatedRequest() else { return }

        state = .loading
        do {
            _ = try await register(request)
            state = .success
            navigate(.registrationCompleted)
        } catch let error as AppError {
            state = .error(.application(error))
        } catch {
            state = .error(.application(.unexpected(.invariantViolation)))
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
