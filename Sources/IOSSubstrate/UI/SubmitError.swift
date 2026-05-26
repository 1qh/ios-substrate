public import SwiftUI

/// Product-neutral submit-triggered error model for SwiftUI alerts.
///
/// Product apps own localized title/message copy and error-code mapping.
/// Substrate owns the stable identity + alert binding behavior so submit
/// failures re-present consistently when a new error replaces the previous one.
public struct SubmitError: Identifiable, Equatable {
    public let id: UUID
    public let title: LocalizedStringKey
    public let message: String

    public init(
        title: LocalizedStringKey,
        message: String,
        id: UUID = UUID(),
    ) {
        self.id = id
        self.title = title
        self.message = message
    }

    public init(
        message: String,
        title: LocalizedStringKey,
        id: UUID = UUID(),
    ) {
        self.init(title: title, message: message, id: id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.message == rhs.message
    }
}

extension View {
    /// Standard alert modifier for submit-triggered failures.
    ///
    /// The binding follows SwiftUI's nil → non-nil presentation pattern. On
    /// dismissal, the modifier clears the binding so a later submit can present
    /// a new alert even when the message text is the same.
    public func errorAlert(
        _ error: Binding<SubmitError?>,
        dismissTitle: LocalizedStringKey = "OK",
    ) -> some View {
        alert(
            error.wrappedValue?.title ?? "Error",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { presented in
                    if !presented {
                        error.wrappedValue = nil
                    }
                },
            ),
            presenting: error.wrappedValue,
        ) { _ in
            Button(dismissTitle, role: .cancel) {
                // SwiftUI clears the binding through the isPresented setter.
            }
        } message: { submitError in
            Text(verbatim: submitError.message)
        }
    }
}
