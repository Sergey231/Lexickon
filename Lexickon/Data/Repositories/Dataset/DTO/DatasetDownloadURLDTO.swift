import Foundation

struct DatasetDownloadURLDTO: Decodable, Sendable {
    let url: URL
    let expiresAt: Date
    let checksumSha256: String
    let compressedSizeBytes: Int64
    let compression: String

    var domainModel: DatasetDownloadURL? {
        guard checksumSha256.count == 64,
              checksumSha256.allSatisfy(\.isHexDigit),
              compressedSizeBytes > 0,
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil,
              let compression = DatasetCompression(rawValue: compression),
              compression != .unsupported else {
            return nil
        }
        return DatasetDownloadURL(
            url: url,
            expiresAt: expiresAt,
            checksumSHA256: checksumSha256,
            compressedSizeBytes: compressedSizeBytes,
            compression: compression
        )
    }
}
