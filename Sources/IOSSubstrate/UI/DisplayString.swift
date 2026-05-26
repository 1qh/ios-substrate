public import SwiftUI

/// Typed user-facing string boundary.
///
/// Use `.localized` for app-owned localized resources and `.userContent` for
/// user-authored pass-through text. Product apps own the actual strings;
/// substrate owns the type-level distinction and SwiftUI rendering bridge.
public enum DisplayString: Equatable {
    case localized(LocalizedStringResource)
    case userContent(String)
}

public protocol DisplayStringConvertible {
    var displayString: DisplayString { get }
}

extension Text {
    public init(_ value: DisplayString) {
        switch value {
        case let .localized(resource):
            self.init(resource)

        case let .userContent(text):
            self.init(verbatim: text)
        }
    }
}
