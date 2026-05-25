import Foundation

public struct AppSubstrateConfig: Equatable, Sendable {
    public let identity: AppIdentity
    public let backendOrigin: BackendOrigin
    public let releaseChannel: ReleaseChannel
    public let telemetry: TelemetryConfig

    public init(
        identity: AppIdentity,
        backendOrigin: BackendOrigin,
        releaseChannel: ReleaseChannel = try! ReleaseChannel(),
        telemetry: TelemetryConfig = TelemetryConfig(),
    ) {
        self.identity = identity
        self.backendOrigin = backendOrigin
        self.releaseChannel = releaseChannel
        self.telemetry = telemetry
    }
}
