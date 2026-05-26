import CoreGraphics
@testable import IOSSubstrate
import Testing

@Test
internal func `flow layout exposes deterministic product neutral defaults`() {
    let layout = FlowLayout()

    #expect(layout.spacing == 8)
    #expect(layout.maxWidth == nil)
}

@Test
internal func `flow layout keeps explicit spacing and width`() {
    let layout = FlowLayout(spacing: 6, maxWidth: 320)

    #expect(layout.spacing == 6)
    #expect(layout.maxWidth == 320)
}
