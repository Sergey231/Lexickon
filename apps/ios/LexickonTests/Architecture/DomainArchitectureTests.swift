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
            "@MainActor"
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

    func testPresentationDoesNotReferenceDataTransferTypes() throws {
        let presentationRoot = repositoryRoot.appending(
            path: "Lexickon/Presentation"
        )
        let sourceURLs = try swiftSourceURLs(at: presentationRoot)

        XCTAssertFalse(sourceURLs.isEmpty)

        let forbiddenFragments = [
            "APIClient",
            "APIRequest",
            "AccessToken",
            "DTO",
            "URLSession"
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

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func swiftSourceURLs(at directory: URL) throws -> [URL] {
        try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: nil
            )?.allObjects as? [URL]
        )
        .filter { $0.pathExtension == "swift" }
    }
}
