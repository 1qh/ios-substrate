import Foundation

public struct BackendOrigin: Equatable, Sendable {
    public enum TrustLevel: Equatable, Sendable {
        case production
        case debugLocal
        case debugRemote
    }

    public let url: URL
    public let trustLevel: TrustLevel

    public init(url: URL, trustLevel: TrustLevel) throws {
        guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
            throw SubstrateConfigError.invalidURL("backend origin requires http or https")
        }
        guard let host = url.host(percentEncoded: false), !host.isEmpty else {
            throw SubstrateConfigError.invalidURL("backend origin requires host")
        }
        if trustLevel == .production {
            guard scheme == "https" else {
                throw SubstrateConfigError.invalidURL("production backend origin requires https")
            }
            guard !Self.isLocalhost(host) else {
                throw SubstrateConfigError.invalidURL("production backend origin cannot be localhost")
            }
        }
        self.url = url
        self.trustLevel = trustLevel
    }

    private static func isLocalhost(_ host: String) -> Bool {
        let normalized = host.lowercased()
        return normalized == "localhost" || normalized == "127.0.0.1" || normalized == "::1"
    }
}
