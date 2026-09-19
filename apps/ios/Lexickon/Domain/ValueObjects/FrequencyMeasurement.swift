struct FrequencyMeasurement: Equatable, Sendable {
    /// Opaque until the SQLite frequency metric contract is finalized.
    let metricIdentifier: String
    let value: Double
}
