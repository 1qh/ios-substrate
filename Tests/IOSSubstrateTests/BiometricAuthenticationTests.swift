@testable import IOSSubstrate
import LocalAuthentication
import Testing

@MainActor
@Test
internal func `biometric current context starts empty and can be discarded`() {
    BiometricAuthentication.discardContext()

    #expect(BiometricAuthentication.currentContext == nil)
}

@MainActor
@Test
internal func `biometric capability probe is safe in simulator environments`() {
    _ = BiometricAuthentication.canEvaluateBiometrics()
}
