import Testing
import Foundation
@testable import AdOrNot

@Test func keychainSaveAndLoad() {
    let key = "test_keychain_\(UUID().uuidString)"
    defer { KeychainHelper.delete(key: key) }

    let saved = KeychainHelper.save(key: key, value: "secret123")
    #expect(saved)

    let loaded = KeychainHelper.load(key: key)
    #expect(loaded == "secret123")
}

@Test func keychainLoadNonexistent() {
    let loaded = KeychainHelper.load(key: "nonexistent_key_\(UUID().uuidString)")
    #expect(loaded == nil)
}

@Test func keychainDelete() {
    let key = "test_delete_\(UUID().uuidString)"
    KeychainHelper.save(key: key, value: "toDelete")
    KeychainHelper.delete(key: key)

    let loaded = KeychainHelper.load(key: key)
    #expect(loaded == nil)
}

@Test func keychainOverwrite() {
    let key = "test_overwrite_\(UUID().uuidString)"
    defer { KeychainHelper.delete(key: key) }

    KeychainHelper.save(key: key, value: "first")
    KeychainHelper.save(key: key, value: "second")

    let loaded = KeychainHelper.load(key: key)
    #expect(loaded == "second")
}
