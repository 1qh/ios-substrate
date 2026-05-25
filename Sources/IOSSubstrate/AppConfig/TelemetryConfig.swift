import Foundation

public struct TelemetryConfig: Equatable, Sendable {
    public let sentryDSN: String?
    public let analyticsAPIKey: String?

    public init(sentryDSN: String? = nil, analyticsAPIKey: String? = nil) {
        self.sentryDSN = Self.normalizedOptional(sentryDSN)
        self.analyticsAPIKey = Self.normalizedOptional(analyticsAPIKey)
    }

    public var sentryEnabled: Bool { sentryDSN != nil }
    public var analyticsEnabled: Bool { analyticsAPIKey != nil }

    private static func normalizedOptional(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}
