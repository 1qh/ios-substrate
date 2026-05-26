public import SwiftUI

/// Product-neutral symbolic effects that keep call sites independent from OS-specific
/// symbol-effect availability while preserving the intended motion semantics.
public enum AdaptiveSymbolEffectKind {
    case bounce
    case breathe
    case pulse
}

extension View {
    /// Adaptive glass surface: Liquid Glass on OS versions that expose it, regular
    /// material fallback everywhere else.
    @ViewBuilder
    public func adaptiveGlass(in shape: some Shape = Capsule(), interactive: Bool = false) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            if interactive {
                glassEffect(.regular.interactive(), in: shape)
            } else {
                glassEffect(.regular, in: shape)
            }
        } else {
            background(.regularMaterial, in: shape)
                .overlay {
                    shape.stroke(Color.white.opacity(0.16), lineWidth: 1)
                }
        }
    }

    /// Adaptive prominent button style: glass prominent on OS versions that expose
    /// it, bordered prominent fallback elsewhere.
    @ViewBuilder
    public func adaptiveProminentGlassButtonStyle() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
        }
    }

    /// Adaptive neutral glass button style with a bordered fallback.
    @ViewBuilder
    public func adaptiveGlassButtonStyle() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    public func adaptiveSymbolEffect(_ effect: AdaptiveSymbolEffectKind) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch effect {
            case .bounce:
                symbolEffect(.bounce)

            case .breathe:
                if #available(iOS 26.0, macOS 26.0, *) {
                    symbolEffect(.breathe)
                } else {
                    symbolEffect(.pulse)
                }

            case .pulse:
                symbolEffect(.pulse)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveSymbolEffect(_ effect: AdaptiveSymbolEffectKind, value: some Equatable) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch effect {
            case .bounce:
                symbolEffect(.bounce, value: value)

            case .breathe:
                if #available(iOS 26.0, macOS 26.0, *) {
                    symbolEffect(.breathe, value: value)
                } else {
                    symbolEffect(.pulse, value: value)
                }

            case .pulse:
                symbolEffect(.pulse, value: value)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveSymbolEffect(
        _ effect: AdaptiveSymbolEffectKind,
        repeating: Bool,
        isActive: Bool = true,
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch effect {
            case .bounce:
                symbolEffect(.bounce, options: repeating ? .repeat(.continuous) : .nonRepeating, isActive: isActive)

            case .breathe:
                if #available(iOS 26.0, macOS 26.0, *) {
                    symbolEffect(.breathe, options: repeating ? .repeat(.continuous) : .nonRepeating, isActive: isActive)
                } else {
                    symbolEffect(.pulse, options: repeating ? .repeat(.continuous) : .nonRepeating, isActive: isActive)
                }

            case .pulse:
                symbolEffect(.pulse, options: repeating ? .repeat(.continuous) : .nonRepeating, isActive: isActive)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveNumericTextTransition() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentTransition(.numericText())
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveNumericTextTransition(value: Double) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentTransition(.numericText(value: value))
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveNumericTextTransition(countsDown: Bool) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentTransition(.numericText(countsDown: countsDown))
        } else {
            self
        }
    }

    @ViewBuilder
    public func adaptiveSymbolReplaceTransition() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentTransition(.symbolEffect(.replace))
        } else {
            contentTransition(.opacity)
        }
    }

    @ViewBuilder
    public func adaptiveSymbolReplaceUpTransition() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentTransition(.symbolEffect(.replace.upUp))
        } else {
            contentTransition(.opacity)
        }
    }
}
