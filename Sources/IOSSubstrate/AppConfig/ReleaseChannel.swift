import Foundation

public struct ReleaseChannel: Equatable, Sendable {
    public static let manual = Self(checkedBetaGroupName: nil, autoInviteTesters: false)

    public let betaGroupName: String?
    public let autoInviteTesters: Bool

    public init(betaGroupName: String? = nil, autoInviteTesters: Bool = false) throws {
        let trimmedGroup = betaGroupName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if autoInviteTesters, trimmedGroup?.isEmpty != false {
            throw SubstrateConfigError.missingValue("betaGroupName required when autoInviteTesters is true")
        }
        self.init(
            checkedBetaGroupName: trimmedGroup?.isEmpty == true ? nil : trimmedGroup,
            autoInviteTesters: autoInviteTesters,
        )
    }

    private init(checkedBetaGroupName: String?, autoInviteTesters: Bool) {
        betaGroupName = checkedBetaGroupName
        self.autoInviteTesters = autoInviteTesters
    }
}
