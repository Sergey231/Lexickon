enum DatasetStatus: String, Equatable, Sendable {
    case active
    case deprecated
    case revoked
}

enum DatasetCompression: String, Equatable, Sendable {
    case gzip
}
