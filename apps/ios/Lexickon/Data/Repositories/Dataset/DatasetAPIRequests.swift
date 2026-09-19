import Foundation

struct DatasetManifestAPIRequest: APIRequest {
    typealias Response = DatasetManifestDTO

    let method = HTTPMethod.get
    let path = "/datasets/manifest"
}

struct DatasetSyncAPIRequest: APIRequest {
    typealias Response = DatasetSyncResponseDTO

    let method = HTTPMethod.post
    let path = "/datasets/sync"
    private let body: DatasetSyncRequestDTO

    init(clientSchemaVersion: Int, installed: [InstalledDataset], wanted: [WantedDataset]) {
        body = DatasetSyncRequestDTO(
            clientSchemaVersion: clientSchemaVersion,
            installed: installed.map(InstalledDatasetDTO.init),
            wanted: wanted.map(WantedDatasetDTO.init)
        )
    }

    func encodeBody(using encoder: JSONEncoder) throws -> Data? {
        try encoder.encode(body)
    }
}

struct DatasetDownloadURLAPIRequest: APIRequest {
    typealias Response = DatasetDownloadURLDTO

    let method = HTTPMethod.post
    let authorization = RequestAuthorization.bearer
    let versionID: DatasetVersionID

    var path: String {
        "/datasets/versions/\(versionID.rawValue)/download-url"
    }
}
