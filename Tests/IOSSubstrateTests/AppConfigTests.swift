import Foundation
import Testing
@testable import IOSSubstrate

@Test func appIdentityRequiresExplicitNames() throws {
    #expect(throws: SubstrateConfigError.missingValue("displayName")) {
        _ = try AppIdentity(displayName: " ", bundleIdentifier: "com.example.app", urlScheme: "example")
    }
}

@Test func productionBackendRejectsLocalhost() throws {
    let url = try #require(URL(string: "http://localhost:8080"))
    #expect(throws: SubstrateConfigError.invalidURL("production backend origin requires https")) {
        _ = try BackendOrigin(url: url, trustLevel: .production)
    }
}

@Test func autoInviteRequiresBetaGroup() throws {
    #expect(throws: SubstrateConfigError.missingValue("betaGroupName required when autoInviteTesters is true")) {
        _ = try ReleaseChannel(autoInviteTesters: true)
    }
}

@Test func telemetryAbsenceIsOff() {
    let config = TelemetryConfig(sentryDSN: " ", analyticsAPIKey: nil)
    #expect(config.sentryEnabled == false)
    #expect(config.analyticsEnabled == false)
}
