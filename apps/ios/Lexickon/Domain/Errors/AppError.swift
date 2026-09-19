enum AppError: Error, Equatable, Sendable {
    case transport(TransportError)
    case authorization(AuthorizationError)
    case dataset(DatasetError)
    case localStorage(LocalStorageError)
    case cancelled
    case unexpected(UnexpectedError)
}

enum TransportError: Error, Equatable, Sendable {
    case offline
    case timedOut
    case unreachable
    case invalidResponse
    case server(statusCode: Int)
}

enum AuthorizationError: Error, Equatable, Sendable {
    case invalidCredentials
    case unauthenticated
    case forbidden
    case sessionExpired
    case accountConflict
}

enum DatasetError: Error, Equatable, Sendable {
    case unavailable
    case notAllowed
    case deprecated
    case revoked
    case incompatibleSchema
    case checksumMismatch
    case notInstalled
    case unknownDataset
}

enum LocalStorageError: Error, Equatable, Sendable {
    case unavailable
    case readFailed
    case writeFailed
    case insufficientSpace
    case corrupted
}

enum UnexpectedError: Error, Equatable, Sendable {
    case dependencyNotConfigured(Dependency)
    case invariantViolation
}

enum Dependency: String, Equatable, Sendable {
    case authRepository
    case userRepository
    case datasetCatalogRepository
    case installedDatasetRepository
    case frequencyRepository
}
