public import Foundation

public struct DebugBackendOverrideStore: Sendable {
    public static let defaultStorageKey = "dev.backendOverrideURL"

    private let key: String
    private let store: any KeyValueStore

    public init(keyNamespace: String, store: any KeyValueStore = UserDefaults.standard) throws {
        let namespace = try keyNamespace.trimmedNonEmpty(or: "keyNamespace").get()
        key = "\(namespace).debug.backend.override"
        self.store = store
    }

    public init(storageKey: String = Self.defaultStorageKey, store: any KeyValueStore = UserDefaults.standard) throws {
        key = try storageKey.trimmedNonEmpty(or: "storageKey").get()
        self.store = store
    }

    public func load() -> URL? {
        guard let raw = store.string(forKey: key) else {
            return nil
        }

        return URL(string: raw)
    }

    public func loadURL(allowedSchemes: Set<String> = ["http", "https"]) throws -> URL? {
        guard let raw = store.string(forKey: key) else {
            return nil
        }

        let config = InfoDictionaryConfig(values: [key: raw])
        guard config.optionalString(key) != nil else {
            return nil
        }

        return try config.requiredURL(key, allowedSchemes: allowedSchemes)
    }

    public func save(_ url: URL?) {
        if let url {
            store.setString(url.absoluteString, forKey: key)
        } else {
            store.removeObject(forKey: key)
        }
    }
}
