import OSLog

/// Central namespace for subsystem-scoped log categories.
///
/// Never interpolate access tokens, passwords, full request/response bodies,
/// email addresses, or other personal data into log messages.
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Lexickon"

    static let app = Logger(subsystem: subsystem, category: "app")
}
