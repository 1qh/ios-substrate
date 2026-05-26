public import Foundation

public enum ISO8601DateCodec {
    public static func parseInternetDateTime(_ value: String) -> Date? {
        date(from: value, options: [.withInternetDateTime, .withFractionalSeconds])
            ?? date(from: value, options: [.withInternetDateTime])
    }

    public static func string(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    private static func date(from value: String, options: ISO8601DateFormatter.Options) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = options
        return formatter.date(from: value)
    }
}
