public import SwiftUI

public struct ShimmerView: View {
    private let cornerRadius: CGFloat
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @State private var phase: CGFloat = -1

    public init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.tertiarySystemFill))
            .overlay(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .accessibilityHidden(true)
            .task { await animate() }
    }

    private var gradient: some View {
        LinearGradient(
            colors: [.clear, Color.white.opacity(0.25), .clear],
            startPoint: .leading,
            endPoint: .trailing,
        )
        .offset(x: phase * 200)
        .opacity(reduceMotion ? 0 : 1)
    }

    private func animate() async {
        guard !reduceMotion else {
            return
        }

        while !Task.isCancelled {
            withAnimation(.linear(duration: 1.1)) {
                phase = 1
            }
            guard await AsyncDelay.completeUnlessCancelled(for: .milliseconds(1200)) else {
                return
            }

            phase = -1
        }
    }
}
