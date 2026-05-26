#if canImport(UIKit)
public import UIKit
#endif

/// Product-neutral haptic intent helpers.
///
/// Product apps own preference gating, analytics, ledgering, and copy. Substrate
/// owns the small, easy-to-drift UIKit generator mapping for common intents.
public enum HapticFeedback {
    public static func light() {
        #if canImport(UIKit)
        impact(.light)
        #endif
    }

    public static func medium() {
        #if canImport(UIKit)
        impact(.medium)
        #endif
    }

    public static func heavy() {
        #if canImport(UIKit)
        impact(.heavy)
        #endif
    }

    public static func success() {
        #if canImport(UIKit)
        notification(.success)
        #endif
    }

    public static func warning() {
        #if canImport(UIKit)
        notification(.warning)
        #endif
    }

    public static func error() {
        #if canImport(UIKit)
        notification(.error)
        #endif
    }

    public static func selection() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    #if canImport(UIKit)
    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    #endif
}
