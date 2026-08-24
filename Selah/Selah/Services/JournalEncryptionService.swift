import Foundation
import CryptoKit
import Security

enum JournalEncryptionError: Error {
    case keychainFailure
    case encryptFailed
    case decryptFailed
}

final class JournalEncryptionService {
    private let keyAccount = "com.lilgroup.selah.journal.master"

    func encrypt(plaintext: String) throws -> (payload: Data, iv: Data, tag: Data) {
        let key = try loadOrCreateKey()
        let iv = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(Data(plaintext.utf8), using: key, nonce: iv)
        return (sealed.ciphertext, Data(iv), sealed.tag)
    }

    func decrypt(payload: Data, iv: Data, tag: Data) throws -> String {
        let key = try loadOrCreateKey()
        let nonce = try AES.GCM.Nonce(data: iv)
        let sealed = try AES.GCM.SealedBox(nonce: nonce, ciphertext: payload, tag: tag)
        let data = try AES.GCM.open(sealed, using: key)
        guard let text = String(data: data, encoding: .utf8) else { throw JournalEncryptionError.decryptFailed }
        return text
    }

    private func loadOrCreateKey() throws -> SymmetricKey {
        if let existing = try readKeyFromKeychain() {
            return existing
        }
        let key = SymmetricKey(size: .bits256)
        try storeKeyInKeychain(key)
        return key
    }

    private func readKeyFromKeychain() throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else { throw JournalEncryptionError.keychainFailure }
        return SymmetricKey(data: data)
    }

    private func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw JournalEncryptionError.keychainFailure }
    }
}
