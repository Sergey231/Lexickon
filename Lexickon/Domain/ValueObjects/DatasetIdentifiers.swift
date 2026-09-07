struct DatasetKey: Hashable, Sendable {
    let rawValue: String
}

struct DatasetVersionID: Hashable, Sendable {
    let rawValue: String
}

struct DatasetVersion: Hashable, Sendable, Comparable {
    let rawValue: String

    static func < (lhs: DatasetVersion, rhs: DatasetVersion) -> Bool {
        guard let lhsComponents = lhs.semanticComponents,
              let rhsComponents = rhs.semanticComponents else {
            return lhs.rawValue < rhs.rawValue
        }
        return lhsComponents.lexicographicallyPrecedes(rhsComponents)
    }

    var isSemanticVersion: Bool {
        semanticComponents != nil
    }

    private var semanticComponents: [Int]? {
        let components = rawValue.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count == 3 else { return nil }
        let values = components.compactMap { component -> Int? in
            guard !component.isEmpty, component.allSatisfy(\.isNumber) else { return nil }
            return Int(component)
        }
        return values.count == 3 ? values : nil
    }
}

struct LanguageCode: Hashable, Sendable {
    let rawValue: String
}

struct DatasetDomain: Hashable, Sendable {
    let rawValue: String
}

struct AccessPlan: Hashable, Sendable {
    let rawValue: String
}
