@testable import IOSSubstrate
import Testing

@Test
internal func `async delay returns false when already cancelled`() async {
    let task = Task {
        await AsyncDelay.completeUnlessCancelled(for: .seconds(5))
    }
    task.cancel()

    #expect(await task.value == false)
}
