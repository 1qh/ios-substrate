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
