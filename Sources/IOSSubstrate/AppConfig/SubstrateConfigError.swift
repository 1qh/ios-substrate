import Foundation

public enum SubstrateConfigError: Error, Equatable, CustomStringConvertible, Sendable {
    case missingValue(String)
    case invalidURL(String)

    public var description: String {
        switch self {
        case let .missingValue(name):
            return "Missing required config: \(name)"
        case let .invalidURL(reason):
            return "Invalid URL config: \(reason)"
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
