import Foundation

public struct DebugBackendOverrideStore: Sendable {
    private let key: String
    private let store: any KeyValueStore

    public init(keyNamespace: String, store: any KeyValueStore = UserDefaults.standard) throws {
        let namespace = try keyNamespace.trimmedNonEmpty(or: "keyNamespace").get()
        key = "\(namespace).debug.backend.override"
        self.store = store
    }

    public func load() -> URL? {
        guard let raw = store.string(forKey: key) else { return nil }
        return URL(string: raw)
    }

    public func save(_ url: URL?) {
        if let url {
            store.setString(url.absoluteString, forKey: key)
        } else {
            store.removeObject(forKey: key)
        }
    }
}
