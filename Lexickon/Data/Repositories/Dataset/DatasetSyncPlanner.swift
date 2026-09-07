import Foundation

struct DatasetSyncPlanner: Sendable {
    func makePlan(
        manifest: DatasetManifest,
        installed: [InstalledDataset],
        request: DatasetSyncRequest,
        serverResponse: DatasetSyncResponseDTO
    ) -> DatasetSyncResult {
        let installedByKey = Dictionary(grouping: installed, by: \.key)
            .compactMapValues { $0.count == 1 ? $0.first : nil }
        let datasetsByPair = Dictionary(
            grouping: manifest.datasets,
            by: { Pair(language: $0.language, domain: $0.domain) }
        )
        let serverActions = Dictionary(
            grouping: serverResponse.actions,
            by: { DatasetKey(rawValue: $0.datasetKey) }
        )

        let wanted = Set(request.wanted.map {
            Pair(language: $0.language, domain: $0.domain)
        })
        .sorted { lhs, rhs in
            if lhs.language.rawValue != rhs.language.rawValue {
                return lhs.language.rawValue < rhs.language.rawValue
            }
            return lhs.domain.rawValue < rhs.domain.rawValue
        }

        let actions = wanted.map { pair -> DatasetSyncAction in
            let candidates = datasetsByPair[pair]
            let dataset = candidates?.count == 1 ? candidates?.first : nil
            let key = dataset?.key ?? DatasetKey(
                rawValue: "\(pair.domain.rawValue.lowercased())-\(pair.language.rawValue.lowercased())"
            )
            let local = installedByKey[key]
            guard let serverAction = serverActions[key]?.first,
                  serverActions[key]?.count == 1 else {
                return action(key: key, status: .unavailable, local: local, target: dataset)
            }

            switch serverAction.domainStatus {
            case .revoked:
                return action(key: key, status: .revoked, local: local, target: nil)
            case .deprecated:
                return action(key: key, status: .deprecated, local: local, target: nil)
            case .notAllowed:
                return action(key: key, status: .notAllowed, local: local, target: dataset)
            case .unknownDataset:
                return action(key: key, status: .unknownDataset, local: local, target: nil)
            case .incompatible:
                return action(key: key, status: .incompatible, local: local, target: dataset)
            case .unavailable:
                return action(key: key, status: .unavailable, local: local, target: dataset)
            case .missing, .upToDate, .updateAvailable:
                return decideAvailableTarget(key: key, local: local, target: dataset)
            }
        }

        return DatasetSyncResult(schemaVersion: serverResponse.schemaVersion, actions: actions)
    }

    private func decideAvailableTarget(
        key: DatasetKey,
        local: InstalledDataset?,
        target: Dataset?
    ) -> DatasetSyncAction {
        guard let target else {
            return action(key: key, status: .unavailable, local: local, target: nil)
        }

        if let unavailableStatus = unavailableStatus(for: target.availability) {
            return action(key: key, status: unavailableStatus, local: local, target: target)
        }

        guard let local else {
            return action(key: key, status: .missing, local: nil, target: target)
        }

        if local.version == target.latestVersion {
            let metadataMatches = local.sqliteSchemaVersion == target.sqliteSchemaVersion
                && local.checksumSHA256.caseInsensitiveCompare(target.checksumSHA256) == .orderedSame
            return action(
                key: key,
                status: metadataMatches ? .upToDate : .unavailable,
                local: local,
                target: target
            )
        }

        guard local.version.isSemanticVersion, target.latestVersion.isSemanticVersion else {
            return action(key: key, status: .unavailable, local: local, target: target)
        }

        // A manifest target must never downgrade a newer local immutable pack.
        let status: DatasetSyncStatus = target.latestVersion > local.version
            ? .updateAvailable
            : .upToDate
        return action(key: key, status: status, local: local, target: target)
    }

    private func unavailableStatus(
        for availability: DatasetAvailability
    ) -> DatasetSyncStatus? {
        switch availability {
        case .available:
            nil
        case .deprecated:
            .deprecated
        case .revoked:
            .revoked
        case .forbidden:
            .notAllowed
        case .incompatible:
            .incompatible
        case .unavailable:
            .unavailable
        }
    }

    private func action(
        key: DatasetKey,
        status: DatasetSyncStatus,
        local: InstalledDataset?,
        target: Dataset?
    ) -> DatasetSyncAction {
        let exposesTarget = status == .missing || status == .updateAvailable
        return DatasetSyncAction(
            key: key,
            status: status,
            installedVersion: local?.version,
            latestVersion: target?.latestVersion,
            latestVersionID: exposesTarget ? target?.latestVersionID : nil,
            sqliteSchemaVersion: exposesTarget ? target?.sqliteSchemaVersion : nil,
            compressedSizeBytes: exposesTarget ? target?.compressedSizeBytes : nil,
            checksumSHA256: exposesTarget ? target?.checksumSHA256 : nil,
            requiredPlan: target?.requiredPlan
        )
    }
}

private struct Pair: Hashable {
    let language: LanguageCode
    let domain: DatasetDomain

    init(language: LanguageCode, domain: DatasetDomain) {
        self.language = LanguageCode(
            rawValue: language.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
        self.domain = DatasetDomain(
            rawValue: domain.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }
}
