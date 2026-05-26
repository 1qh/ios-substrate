public import Foundation

/// Typed JSON-backed `UserDefaults` storage for small app-local Codable values.
///
/// Product apps own the key names and payload types. Substrate owns the
/// encode/decode/remove mechanics so local caches do not drift into untyped
/// dictionaries or repeated JSON boilerplate.
public struct CodableDefaultsStore<Value: Codable> {
    private let key: String
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        key: String,
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
    ) {
        self.key = key
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    public func save(_ value: Value) throws {
        let data = try encoder.encode(value)
        defaults.set(data, forKey: key)
    }

    public func load() throws -> Value? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try decoder.decode(Value.self, from: data)
    }

    public func remove() {
        defaults.removeObject(forKey: key)
    }
}
