enum DatasetStatus: String, Equatable, Sendable {
    case active
    case deprecated
    case revoked
    case unavailable
}

enum DatasetCompression: String, Equatable, Sendable {
    case gzip
    case unsupported
}

enum DatasetAvailability: String, Equatable, Sendable, CaseIterable {
    case available
    case deprecated
    case revoked
    case forbidden
    case incompatible
    case unavailable
}
