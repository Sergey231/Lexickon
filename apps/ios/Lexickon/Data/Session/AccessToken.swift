import Foundation

struct AccessToken: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    let rawValue: String

    init?(rawValue: String) {
        let forbiddenCharacters = CharacterSet.whitespacesAndNewlines
            .union(.controlCharacters)
        guard
            !rawValue.isEmpty,
            rawValue.rangeOfCharacter(from: forbiddenCharacters) == nil
        else {
            return nil
        }
        self.rawValue = rawValue
    }

    var description: String { "<redacted>" }
    var debugDescription: String { "<redacted>" }
}
