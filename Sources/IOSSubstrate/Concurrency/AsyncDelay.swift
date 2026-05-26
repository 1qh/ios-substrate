import Foundation

public enum AsyncDelay {
    public static let typeaheadDebounce = Duration.milliseconds(300)

    public static func completeUnlessCancelled(for duration: Duration) async -> Bool {
        do {
            try await Task.sleep(for: duration)
            return !Task.isCancelled
        } catch {
            return false
        }
    }
}
