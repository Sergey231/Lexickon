import Foundation

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

enum AuthEmailValidator {
    static func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, let domain = parts.last else { return false }
        return !parts[0].isEmpty && domain.contains(".") && !domain.hasSuffix(".")
    }
}
