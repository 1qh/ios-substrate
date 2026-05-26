public import Foundation

public enum Base64URL {
    public static func decode(_ value: String) -> Data? {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            return nil
        }

        var buffer = normalized
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = buffer.count % 4
        if remainder == 1 {
            return nil
        }
        if remainder > 0 {
            buffer.append(String(repeating: "=", count: 4 - remainder))
        }
        return Data(base64Encoded: buffer)
    }

    public static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
