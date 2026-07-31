struct LoginRequest: Equatable, Sendable {
    let email: String
    let password: String
}

struct RegistrationRequest: Equatable, Sendable {
    let email: String
    let password: String
}
