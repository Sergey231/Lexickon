import Foundation

struct AuthRegistrationAPIRequest: APIRequest {
    typealias Response = UserDTO

    let method = HTTPMethod.post
    let path = "/auth/register"
    private let body: AuthCredentialsDTO

    init(_ request: RegistrationRequest) {
        body = AuthCredentialsDTO(email: request.email, password: request.password)
    }

    func encodeBody(using encoder: JSONEncoder) throws -> Data? {
        try encoder.encode(body)
    }
}

struct AuthLoginAPIRequest: APIRequest {
    typealias Response = AuthTokenDTO

    let method = HTTPMethod.post
    let path = "/auth/login"
    private let body: AuthCredentialsDTO

    init(_ request: LoginRequest) {
        body = AuthCredentialsDTO(email: request.email, password: request.password)
    }

    func encodeBody(using encoder: JSONEncoder) throws -> Data? {
        try encoder.encode(body)
    }
}

struct CurrentUserAPIRequest: APIRequest {
    typealias Response = UserDTO

    let method = HTTPMethod.get
    let path = "/me"
    let authorization = RequestAuthorization.bearer
}

struct AuthCredentialsDTO: Encodable, Sendable {
    let email: String
    let password: String
}

struct AuthTokenDTO: Decodable, Sendable {
    let accessToken: String
}

struct UserDTO: Decodable, Sendable {
    let id: String
    let email: String
    let settings: UserSettingsDTO

    func domainModel() -> User {
        User(
            id: UserID(rawValue: id),
            email: email,
            settings: settings.domainModel()
        )
    }
}

struct UserSettingsDTO: Decodable, Sendable {
    let preferredLanguage: String
    let selectedDomains: [String]
    let offlineMode: Bool
    let syncOverCellular: Bool

    func domainModel() -> UserSettings {
        UserSettings(
            preferredLanguage: LanguageCode(rawValue: preferredLanguage),
            selectedDomains: selectedDomains.map(DatasetDomain.init(rawValue:)),
            offlineMode: offlineMode,
            syncOverCellular: syncOverCellular
        )
    }
}
