import Foundation

public enum SubstrateConfigError: Error, Equatable, CustomStringConvertible, Sendable {
    case invalidURL(String)
    case missingValue(String)

    public var description: String {
        switch self {
        case let .invalidURL(reason):
            "Invalid URL config: \(reason)"

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
