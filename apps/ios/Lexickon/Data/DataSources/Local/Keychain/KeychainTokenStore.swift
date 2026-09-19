import Foundation
import Security

struct KeychainTokenStore: TokenStore {
    private let service: String
    private let account: String

    init(service: String, account: String = "access-token") {
        self.service = service
        self.account = account
    }

    func loadAccessToken() async throws -> AccessToken? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw TokenStoreError.readFailed(status: status)
        }
        guard
            let data = item as? Data,
            let value = String(data: data, encoding: .utf8),
            let token = AccessToken(rawValue: value)
        else {
            throw TokenStoreError.corrupted
        }
        return token
    }

    func saveAccessToken(_ token: AccessToken) async throws {
        let data = Data(token.rawValue.utf8)
        let attributes = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecItemNotFound {
            var query = baseQuery
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw TokenStoreError.writeFailed(status: addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw TokenStoreError.writeFailed(status: updateStatus)
        }
    }

    func deleteAccessToken() async throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.deleteFailed(status: status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
