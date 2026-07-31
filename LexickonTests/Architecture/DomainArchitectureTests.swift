import Foundation
import XCTest

final class DomainArchitectureTests: XCTestCase {
    func testDomainDoesNotReferencePresentationOrInfrastructureAPIs() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let domainRoot = repositoryRoot.appending(path: "Lexickon/Domain")

        let sourceURLs = try XCTUnwrap(
            FileManager.default.enumerator(
                at: domainRoot,
                includingPropertiesForKeys: nil
            )?.allObjects as? [URL]
        )
        .filter { $0.pathExtension == "swift" }

        XCTAssertFalse(sourceURLs.isEmpty)

        let forbiddenFragments = [
            "import SwiftUI",
            "import UIKit",
            "import Security",
            "import SQLite3",
            "URLSession",
            "Keychain",
            "SQLiteConnection",
            "@MainActor",
        ]

        for sourceURL in sourceURLs {
            let source = try String(contentsOf: sourceURL, encoding: .utf8)

            for fragment in forbiddenFragments {
                XCTAssertFalse(
                    source.contains(fragment),
                    "\(sourceURL.lastPathComponent) contains forbidden '\(fragment)'"
                )
            }
        }
    }
}
