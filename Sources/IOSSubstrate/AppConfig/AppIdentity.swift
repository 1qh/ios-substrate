import Foundation

public struct AppIdentity: Equatable, Sendable {
    public let displayName: String
    public let bundleIdentifier: String
    public let urlScheme: String
    public let appStoreAppID: String?

    public init(
        displayName: String,
        bundleIdentifier: String,
        urlScheme: String,
        appStoreAppID: String? = nil,
    ) throws {
        let normalizedDisplayName = displayName.trimmedNonEmpty(or: "displayName")
        let normalizedBundleIdentifier = bundleIdentifier.trimmedNonEmpty(or: "bundleIdentifier")
        let normalizedURLScheme = urlScheme.trimmedNonEmpty(or: "urlScheme")
        let normalizedAppStoreID = appStoreAppID?.trimmingCharacters(in: .whitespacesAndNewlines)

        self.displayName = try normalizedDisplayName.get()
        self.bundleIdentifier = try normalizedBundleIdentifier.get()
        self.urlScheme = try normalizedURLScheme.get()
        self.appStoreAppID = normalizedAppStoreID?.isEmpty == true ? nil : normalizedAppStoreID
    }
}
