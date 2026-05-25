import Foundation

public enum SubstrateConfigError: Error, Equatable, CustomStringConvertible, Sendable {
    case invalidURL(String)
    case invalidValue(name: String, reason: String)
    case missingValue(String)

    public var description: String {
        switch self {
        case let .invalidURL(reason):
            "Invalid URL config: \(reason)"

        case let .invalidValue(name, reason):
            "Invalid config value for \(name): \(reason)"

        case let .missingValue(name):
            "Missing required config: \(name)"
        }
    }
}

extension String {
    package func trimmedNonEmpty(or name: String) -> Result<String, SubstrateConfigError> {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(.missingValue(name))
        }

        return .success(trimmed)
    }
}
