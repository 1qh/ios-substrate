public import SwiftUI

public struct PressScaleButtonStyle: ButtonStyle {
    private let scale: CGFloat

    public init(scale: CGFloat = 0.97) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressScaleBody(configuration: configuration, scale: scale)
    }

    private struct PressScaleBody: View {
        let configuration: Configuration
        let scale: CGFloat
        @Environment(\.accessibilityReduceMotion)
        private var reduceMotion

        var body: some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? scale : 1)
                .animation(
                    reduceMotion ? nil : .spring(duration: 0.25, bounce: 0.35),
                    value: configuration.isPressed,
                )
        }
    }
}

extension ButtonStyle where Self == PressScaleButtonStyle {
    public static var pressScale: PressScaleButtonStyle {
        PressScaleButtonStyle()
    }
}
