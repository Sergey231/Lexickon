struct FrequencyResult: Equatable, Sendable {
    let query: FrequencyQuery
    let matchedText: String
    let measurement: FrequencyMeasurement
}
