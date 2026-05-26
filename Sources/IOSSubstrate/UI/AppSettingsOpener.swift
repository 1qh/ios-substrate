#if canImport(UIKit)
public import UIKit
#endif

/// Product-neutral helper for opening the current app's Settings page.
///
/// Product apps own the surrounding copy and permission policy. Substrate owns
/// the easy-to-drift `UIApplication.openSettingsURLString` construction and
/// UIApplication handoff.
public enum AppSettingsOpener {
    #if canImport(UIKit)
    public static var settingsURL: URL? {
        URL(string: UIApplication.openSettingsURLString)
    }

    @preconcurrency
    @MainActor
    public static func open(completion: ((Bool) -> Void)? = nil) {
        guard let url = settingsURL else {
            completion?(false)
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            completion?(success)
        }
    }
    #endif
}
