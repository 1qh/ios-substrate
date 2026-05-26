import Foundation

public struct AppVersionInfo: Equatable, Sendable {
    public static let shortVersionKey = "CFBundleShortVersionString"
    public static let buildKey = "CFBundleVersion"

    public let appName: String
    public let shortVersion: String
    public let build: String

    public init(appName: String, shortVersion: String, build: String) throws {
        self.appName = try Self.normalizedRequired(appName, name: "appName")
        self.shortVersion = try Self.normalizedRequired(shortVersion, name: "shortVersion")
        self.build = try Self.normalizedRequired(build, name: "build")
    }

    public var displayString: String {
        "\(appName) \(shortVersion) (\(build))"
    }

    public var buildNumber: Int? {
        Int(build)
    }

    public static func read(
        appName: String,
        from info: InfoDictionaryConfig,
        shortVersionKey: String = Self.shortVersionKey,
        buildKey: String = Self.buildKey,
    ) throws -> Self {
        try Self(
            appName: appName,
            shortVersion: info.requiredString(shortVersionKey),
            build: info.requiredString(buildKey),
        )
    }

    public static func currentBuild(
        from info: InfoDictionaryConfig,
        buildKey: String = Self.buildKey,
    ) throws -> Int {
        try info.requiredInt(buildKey)
    }

    public static func displayString(
        appName: String,
        from info: InfoDictionaryConfig,
        shortVersionKey: String = Self.shortVersionKey,
        buildKey: String = Self.buildKey,
    ) throws -> String {
        try read(
            appName: appName,
            from: info,
            shortVersionKey: shortVersionKey,
            buildKey: buildKey,
        ).displayString
    }

    private static func normalizedRequired(_ value: String, name: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SubstrateConfigError.missingValue(name)
        }

        return trimmed
    }
}
