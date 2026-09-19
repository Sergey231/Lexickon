import Foundation

#if DEBUG
actor UITestAuthRepository: AuthRepository {
    private let defaults: UserDefaults
    private let signedInKey = "UITestAuthRepository.signedIn"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if ProcessInfo.processInfo.arguments.contains("--uitest-reset-auth") {
            defaults.removeObject(forKey: signedInKey)
        }
    }

    func register(_ request: RegistrationRequest) async throws -> User {
        guard request.email != "taken@example.com" else {
            throw AppError.authorization(.accountConflict)
        }
        return User(
            id: UserID(rawValue: "uitest-user"),
            email: request.email,
            settings: UserSettings(
                preferredLanguage: LanguageCode(rawValue: "en"),
                selectedDomains: [],
                offlineMode: false,
                syncOverCellular: false
            )
        )
    }

    func login(_ request: LoginRequest) async throws -> AuthenticationState {
        guard request.email != "wrong@example.com" else {
            throw AppError.authorization(.invalidCredentials)
        }
        defaults.set(true, forKey: signedInKey)
        return .signedIn
    }

    func logout() async throws {
        defaults.removeObject(forKey: signedInKey)
    }

    func authenticationState() async throws -> AuthenticationState {
        defaults.bool(forKey: signedInKey) ? .signedIn : .signedOut
    }
}
#endif
