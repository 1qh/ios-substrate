public import Foundation
@preconcurrency public import LocalAuthentication

@preconcurrency
@MainActor
public enum BiometricAuthentication {
    public private(set) static var currentContext: LAContext?

    public static func discardContext() {
        currentContext = nil
    }

    nonisolated public static func nonInteractiveContext() -> LAContext {
        let context = LAContext()
        context.interactionNotAllowed = true
        return context
    }

    public static func canEvaluateBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public static func authenticate(
        reason: String,
        allowableReuseDuration: TimeInterval = 10,
        fallbackToDeviceOwnerAuthentication: Bool = false,
    ) async -> LAContext? {
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = allowableReuseDuration
        var evalError: NSError?
        let policy: LAPolicy
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evalError) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        } else if fallbackToDeviceOwnerAuthentication {
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &evalError) else {
                return nil
            }

            policy = .deviceOwnerAuthentication
        } else {
            return nil
        }

        do {
            let ok = try await context.evaluatePolicy(policy, localizedReason: reason)
            guard ok else {
                return nil
            }

            currentContext = context
            return context
        } catch {
            return nil
        }
    }
}
