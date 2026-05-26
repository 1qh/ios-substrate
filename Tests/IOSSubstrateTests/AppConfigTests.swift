import Foundation
@testable import IOSSubstrate
import Testing

@Test
internal func `app identity requires explicit names`() throws {
    #expect(throws: SubstrateConfigError.missingValue("displayName")) {
        _ = try AppIdentity(displayName: " ", bundleIdentifier: "com.example.app", urlScheme: "example")
    }
}

@Test
internal func `production backend rejects localhost`() throws {
    let url = try #require(URL(string: "http://localhost:8080"))
    #expect(throws: SubstrateConfigError.invalidURL("production backend origin requires https")) {
        _ = try BackendOrigin(url: url, trustLevel: .production)
    }
}

@Test
internal func `auto invite requires beta group`() throws {
    #expect(throws: SubstrateConfigError.missingValue("betaGroupName required when autoInviteTesters is true")) {
        _ = try ReleaseChannel(autoInviteTesters: true)
    }
}

@Test
internal func `telemetry absence is off`() {
    let config = TelemetryConfig(sentryDSN: " ", analyticsAPIKey: nil, deploymentEnvironment: " ")
    #expect(config.sentryEnabled == false)
    #expect(config.analyticsEnabled == false)
    #expect(config.deploymentEnvironment == nil)
}

@Test
internal func `telemetry reads bundle and launch environment values`() {
    let info = InfoDictionaryConfig(values: [
        TelemetryConfig.sentryDSNKey: "bundle-dsn",
        TelemetryConfig.analyticsAPIKeyKey: "bundle-analytics",
        TelemetryConfig.deploymentEnvironmentKey: "prod",
    ])

    let config = TelemetryConfig.read(
        from: info,
        environment: [TelemetryConfig.sentryDSNKey: " env-dsn "],
    )

    #expect(config.sentryDSN == "env-dsn")
    #expect(config.analyticsAPIKey == "bundle-analytics")
    #expect(config.deploymentEnvironment == "prod")
    #expect(TelemetryConfig.defaultTracesSampleRate == 0.1)
}

@Test
internal func `info dictionary config trims required string values`() throws {
    let config = InfoDictionaryConfig(values: ["APP_NAME": " Example "])
    #expect(try config.requiredString("APP_NAME") == "Example")
}

@Test
internal func `info dictionary config treats unresolved xcode placeholders as absent`() throws {
    let config = InfoDictionaryConfig(values: ["POSTHOG_API_KEY": "$(POSTHOG_API_KEY)"])
    #expect(config.optionalString("POSTHOG_API_KEY") == nil)
    #expect(throws: SubstrateConfigError.missingValue("POSTHOG_API_KEY")) {
        _ = try config.requiredString("POSTHOG_API_KEY")
    }
}

@Test
internal func `info dictionary config lets launch environment override optional strings`() {
    let config = InfoDictionaryConfig(values: ["SENTRY_DSN": "bundle-dsn"])

    #expect(config.optionalString("SENTRY_DSN", environment: ["SENTRY_DSN": " env-dsn "]) == "env-dsn")
    #expect(config.optionalString("SENTRY_DSN", environment: ["SENTRY_DSN": "$(SENTRY_DSN)"]) == "bundle-dsn")
    #expect(config.optionalString("SENTRY_DSN", environment: [:]) == "bundle-dsn")
}

@Test
internal func `info dictionary config parses explicit booleans`() throws {
    let config = InfoDictionaryConfig(dictionary: ["FEATURE_ON": "yes", "FEATURE_OFF": 0])
    #expect(try config.bool("FEATURE_ON") == true)
    #expect(try config.bool("FEATURE_OFF", default: true) == false)
}

@Test
internal func `info dictionary config rejects malformed booleans`() throws {
    let config = InfoDictionaryConfig(values: ["FEATURE": "sometimes"])
    #expect(throws: SubstrateConfigError.invalidValue(name: "FEATURE", reason: "expected boolean")) {
        _ = try config.bool("FEATURE")
    }
}

@Test
internal func `info dictionary config validates required URLs`() throws {
    let config = InfoDictionaryConfig(values: ["API_BASE": "https://example.test"])
    #expect(try config.requiredURL("API_BASE").host() == "example.test")
}

@Test
internal func `info dictionary config rejects URLs without allowed origin`() throws {
    let config = InfoDictionaryConfig(values: ["API_BASE": "file:///tmp/data.json"])
    #expect(throws: SubstrateConfigError.invalidURL("API_BASE requires URL with allowed scheme")) {
        _ = try config.requiredURL("API_BASE")
    }
}

@Test
internal func `debug backend override uses canonical storage key`() throws {
    #expect(DebugBackendOverrideStore.defaultStorageKey == "dev.backendOverrideURL")
    let store = InMemoryKeyValueStore()
    let overrides = try DebugBackendOverrideStore(store: store)
    let url = try #require(URL(string: "https://local.example.test"))
    overrides.save(url)

    #expect(store.string(forKey: DebugBackendOverrideStore.defaultStorageKey) == "https://local.example.test")
    #expect(try overrides.loadURL() == url)
}

@Test
internal func `debug backend override treats empty and placeholder values as absent`() throws {
    let store = InMemoryKeyValueStore()
    let overrides = try DebugBackendOverrideStore(store: store)

    store.setString(" ", forKey: DebugBackendOverrideStore.defaultStorageKey)
    #expect(try overrides.loadURL() == nil)

    store.setString("$(DEV_BACKEND)", forKey: DebugBackendOverrideStore.defaultStorageKey)
    #expect(try overrides.loadURL() == nil)
}

@Test
internal func `debug backend override rejects non origin URLs`() throws {
    let store = InMemoryKeyValueStore()
    let overrides = try DebugBackendOverrideStore(store: store)
    store.setString("file:///tmp/data.json", forKey: DebugBackendOverrideStore.defaultStorageKey)

    #expect(throws: SubstrateConfigError
        .invalidURL("\(DebugBackendOverrideStore.defaultStorageKey) requires URL with allowed scheme")) {
        _ = try overrides.loadURL()
    }
}

internal final class InMemoryKeyValueStore: KeyValueStore, @unchecked Sendable {
    private var values = [String: String]()

    internal func string(forKey key: String) -> String? {
        values[key]
    }

    internal func setString(_ value: String, forKey key: String) {
        values[key] = value
    }

    internal func removeObject(forKey key: String) {
        values.removeValue(forKey: key)
    }
}

private struct DefaultsPayload: Codable, Equatable {
    let name: String
    let count: Int
}

@Test
internal func `codable defaults store round trips and removes typed payloads`() throws {
    let suiteName = "codable-defaults-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    let store = CodableDefaultsStore<DefaultsPayload>(key: "payload", defaults: defaults)

    #expect(try store.load() == nil)
    try store.save(DefaultsPayload(name: "ready", count: 2))
    #expect(try store.load() == DefaultsPayload(name: "ready", count: 2))

    store.remove()
    #expect(try store.load() == nil)
}

@Test
internal func `app version info reads display and numeric build from info dictionary`() throws {
    let info = InfoDictionaryConfig(values: [
        AppVersionInfo.shortVersionKey: " 1.2.3 ",
        AppVersionInfo.buildKey: "42",
    ])

    let version = try AppVersionInfo.read(appName: "  Map  ", from: info)

    #expect(version.appName == "Map")
    #expect(version.shortVersion == "1.2.3")
    #expect(version.build == "42")
    #expect(version.buildNumber == 42)
    #expect(version.displayString == "Map 1.2.3 (42)")
    #expect(try AppVersionInfo.currentBuild(from: info) == 42)
    #expect(try AppVersionInfo.displayString(appName: "Map", from: info) == "Map 1.2.3 (42)")
}

@Test
internal func `app version info rejects missing or non numeric builds`() throws {
    let missing = InfoDictionaryConfig(values: [:])
    #expect(throws: SubstrateConfigError.self) {
        _ = try AppVersionInfo.currentBuild(from: missing)
    }

    let nonNumeric = InfoDictionaryConfig(values: [AppVersionInfo.buildKey: "abc"])
    #expect(throws: SubstrateConfigError.self) {
        _ = try AppVersionInfo.currentBuild(from: nonNumeric)
    }
}

@Test
internal func `iso8601 date codec parses fractional and whole second internet dates`() throws {
    let fractional = try #require(ISO8601DateCodec.parseInternetDateTime("2026-05-26T05:30:12.345Z"))
    let wholeSecond = try #require(ISO8601DateCodec.parseInternetDateTime("2026-05-26T05:30:12Z"))

    #expect(fractional.timeIntervalSince1970 > wholeSecond.timeIntervalSince1970)
    #expect(ISO8601DateCodec.parseInternetDateTime("2026-05-26") == nil)
}

@Test
internal func `iso8601 date codec formats fractional internet dates`() {
    let date = Date(timeIntervalSince1970: 1_779_773_412.345)
    let value = ISO8601DateCodec.string(from: date)

    #expect(value.contains("T"))
    #expect(value.contains("."))
    #expect(value.hasSuffix("Z"))
    #expect(ISO8601DateCodec.parseInternetDateTime(value) == date)
}
