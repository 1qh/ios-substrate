import Foundation
@testable import IOSSubstrate
import Testing

@Test
internal func `base64 url decodes unpadded url safe values`() throws {
    let decoded = try #require(Base64URL.decode("SGVsbG8td29ybGRf"))
    #expect(String(data: decoded, encoding: .utf8) == "Hello-world_")
}

@Test
internal func `base64 url encodes without padding and round trips`() {
    let data = Data([0xFB, 0xFF, 0x00, 0x01])
    let encoded = Base64URL.encode(data)

    #expect(encoded == "-_8AAQ")
    #expect(Base64URL.decode(encoded) == data)
}

@Test
internal func `base64 url rejects impossible padding remainder`() {
    #expect(Base64URL.decode("A") == nil)
    #expect(Base64URL.decode(" ") == nil)
}
