#if canImport(UIKit)
public import UIKit
#endif

/// Product-neutral helper for handing a URL to iOS.
///
/// Product apps own which URL to build and what to show when opening fails.
/// Substrate owns the UIKit handoff shape so completion behavior and
/// `canOpenURL` checks do not fork across apps.
public enum ExternalURLOpener {
    #if canImport(UIKit)
    public typealias OpenOptions = [UIApplication.OpenExternalURLOptionsKey: Any]

    @preconcurrency
    @MainActor
    public static func canOpen(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }

    @preconcurrency
    @MainActor
    public static func open(
        _ url: URL,
        options: OpenOptions = [:],
        completion: ((Bool) -> Void)? = nil,
    ) {
        UIApplication.shared.open(url, options: options) { success in
            completion?(success)
        }
    }
    #endif
}
