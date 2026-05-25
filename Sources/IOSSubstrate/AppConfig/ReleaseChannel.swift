import Foundation

public struct ReleaseChannel: Equatable, Sendable {
    public let betaGroupName: String?
    public let autoInviteTesters: Bool

    public init(betaGroupName: String? = nil, autoInviteTesters: Bool = false) throws {
        let trimmedGroup = betaGroupName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if autoInviteTesters, trimmedGroup?.isEmpty != false {
            throw SubstrateConfigError.missingValue("betaGroupName required when autoInviteTesters is true")
        }
        self.betaGroupName = trimmedGroup?.isEmpty == true ? nil : trimmedGroup
        self.autoInviteTesters = autoInviteTesters
    }
}
