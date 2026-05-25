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
    let config = TelemetryConfig(sentryDSN: " ", analyticsAPIKey: nil)
    #expect(config.sentryEnabled == false)
    #expect(config.analyticsEnabled == false)
}

@Test
internal func `info dictionary config trims required string values`() throws {
    let config = InfoDictionaryConfig(values: ["APP_NAME": " Example "])
    #expect(try config.requiredString("APP_NAME") == "Example")
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
