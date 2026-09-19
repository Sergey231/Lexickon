import Foundation
import Security
import XCTest
@testable import Lexickon

final class KeychainTokenStoreTests: XCTestCase, @unchecked Sendable {
    func testSavesReadsAndDeletesTokenInIsolatedService() async throws {
        let service = "com.lexickon.tests.\(UUID().uuidString)"
        let store = KeychainTokenStore(service: service)
        let token = try XCTUnwrap(AccessToken(rawValue: "keychain-only-token"))

        try await store.saveAccessToken(token)
        let loadedToken = try await store.loadAccessToken()
        XCTAssertEqual(loadedToken, token)

        try await store.deleteAccessToken()
        let deletedToken = try await store.loadAccessToken()
        XCTAssertNil(deletedToken)
    }

    func testReportsCorruptedKeychainValue() async throws {
        let service = "com.lexickon.tests.\(UUID().uuidString)"
        let store = KeychainTokenStore(service: service)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "access-token",
            kSecValueData as String: Data([0xFF, 0xFE])
        ]
        XCTAssertEqual(SecItemAdd(query as CFDictionary, nil), errSecSuccess)

        do {
            _ = try await store.loadAccessToken()
            XCTFail("Corrupted data must not become a token")
        } catch let error as TokenStoreError {
            XCTAssertEqual(error, .corrupted)
        }

        try await store.deleteAccessToken()
    }
}
