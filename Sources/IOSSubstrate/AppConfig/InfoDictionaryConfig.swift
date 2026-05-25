public import Foundation

public struct InfoDictionaryConfig: Equatable, Sendable {
    private let values: [String: String]

    public init(values: [String: String]) {
        self.values = values.reduce(into: [:]) { result, pair in
            let key = pair.key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Self.normalizedString(pair.value), !key.isEmpty else {
                return
            }

            result[key] = value
        }
    }

    public init(dictionary: [String: Any]) {
        self.init(values: dictionary.compactMapValues(Self.stringValue))
    }

    public init(keys: [String], bundle: Bundle = .main) {
        let values = keys.reduce(into: [String: String]()) { result, key in
            guard let value = bundle.object(forInfoDictionaryKey: key).flatMap(Self.stringValue) else {
                return
            }

            result[key] = value
        }
        self.init(values: values)
    }

    public func optionalString(_ key: String) -> String? {
        values[key]
    }

    public func requiredString(_ key: String) throws -> String {
        guard let value = optionalString(key) else {
            throw SubstrateConfigError.missingValue(key)
        }

        return value
    }

    public func bool(_ key: String, default defaultValue: Bool = false) throws -> Bool {
        guard let value = optionalString(key) else {
            return defaultValue
        }

        let normalizedValue = value.lowercased()
        if ["1", "true", "yes"].contains(normalizedValue) {
            return true
        }

        if ["0", "false", "no"].contains(normalizedValue) {
            return false
        }

        throw SubstrateConfigError.invalidValue(name: key, reason: "expected boolean")
    }

    public func requiredInt(_ key: String) throws -> Int {
        let value = try requiredString(key)
        guard let intValue = Int(value) else {
            throw SubstrateConfigError.invalidValue(name: key, reason: "expected integer")
        }

        return intValue
    }

    public func requiredURL(
        _ key: String,
        allowedSchemes: Set<String> = ["http", "https"],
    ) throws -> URL {
        let raw = try requiredString(key)
        guard let url = URL(string: raw) else {
            throw SubstrateConfigError.invalidURL("\(key) requires URL with allowed scheme")
        }
        guard let scheme = url.scheme?.lowercased(), allowedSchemes.contains(scheme) else {
            throw SubstrateConfigError.invalidURL("\(key) requires URL with allowed scheme")
        }
        guard url.host(percentEncoded: false)?.isEmpty == false else {
            throw SubstrateConfigError.invalidURL("\(key) requires URL with allowed scheme")
        }

        return url
    }

    private static func stringValue(_ raw: Any) -> String? {
        switch raw {
        case let string as String:
            normalizedString(string)

        case let bool as Bool:
            bool ? "true" : "false"

        case let int as Int:
            String(int)

        case let double as Double:
            String(double)

        default:
            nil
        }
    }

    private static func normalizedString(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        guard !(trimmed.hasPrefix("$(") && trimmed.hasSuffix(")")) else {
            return nil
        }

        return trimmed
    }
}
