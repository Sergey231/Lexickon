protocol SessionAuthorizing: Sendable {
    func bearerToken() async -> AccessToken?
    func didReceiveUnauthorized() async
}
