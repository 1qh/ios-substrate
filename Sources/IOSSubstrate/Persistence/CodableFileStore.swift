public import Foundation

/// Typed JSON-backed file storage for small durable Codable payloads.
///
/// Product apps own file locations, retention policy, and domain mutation rules.
/// Substrate owns the encode/decode/atomic-write mechanics so app queues do not
/// repeat fragile `Data(contentsOf:)` + JSON boilerplate.
public struct CodableFileStore<Value: Codable> {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let defaultValue: Value

    public init(
        fileURL: URL,
        defaultValue: Value,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
    ) {
        self.fileURL = fileURL
        self.defaultValue = defaultValue
        self.encoder = encoder
        self.decoder = decoder
    }

    public func load() throws -> Value {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return defaultValue
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Value.self, from: data)
    }

    public func save(_ value: Value) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: .atomic)
    }

    public func remove() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
    }
}
