import Foundation

public struct TelemetryConfig: Equatable, Sendable {
    public static let sentryDSNKey = "SENTRY_DSN"
    public static let analyticsAPIKeyKey = "POSTHOG_API_KEY"
    public static let deploymentEnvironmentKey = "DEPLOYMENT_ENV"
    public static let defaultTracesSampleRate = 0.1

    public let sentryDSN: String?
    public let analyticsAPIKey: String?
    public let deploymentEnvironment: String?

    public init(
        sentryDSN: String? = nil,
        analyticsAPIKey: String? = nil,
        deploymentEnvironment: String? = nil,
    ) {
        self.sentryDSN = Self.normalizedOptional(sentryDSN)
        self.analyticsAPIKey = Self.normalizedOptional(analyticsAPIKey)
        self.deploymentEnvironment = Self.normalizedOptional(deploymentEnvironment)
    }

    public static func read(
        from info: InfoDictionaryConfig,
        environment: [String: String] = [:],
        sentryDSNKey: String = Self.sentryDSNKey,
        analyticsAPIKeyKey: String = Self.analyticsAPIKeyKey,
        deploymentEnvironmentKey: String = Self.deploymentEnvironmentKey,
    ) -> Self {
        Self(
            sentryDSN: info.optionalString(sentryDSNKey, environment: environment),
            analyticsAPIKey: info.optionalString(analyticsAPIKeyKey, environment: environment),
            deploymentEnvironment: info.optionalString(deploymentEnvironmentKey, environment: environment),
        )
    }

    public var sentryEnabled: Bool {
        sentryDSN != nil
    }

    public var analyticsEnabled: Bool {
        analyticsAPIKey != nil
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}
