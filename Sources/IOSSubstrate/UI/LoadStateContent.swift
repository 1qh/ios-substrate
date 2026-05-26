public import SwiftUI

/// Product-neutral renderer for `LoadState` surfaces.
///
/// Substrate owns the exhaustive state switch. Product apps own loading chrome,
/// success content, empty copy, failure copy, and retry actions through view
/// builders so no business language or policy leaks into the reusable layer.
public struct LoadStateContent<
    Value: Sendable,
    Failure: Sendable,
    LoadingContent: View,
    Content: View,
    EmptyContent: View,
    FailedContent: View,
>: View {
    private let state: LoadState<Value, Failure>
    private let loadingContent: () -> LoadingContent
    private let content: (Value) -> Content
    private let emptyContent: () -> EmptyContent
    private let failedContent: (Failure) -> FailedContent

    public init(
        state: LoadState<Value, Failure>,
        @ViewBuilder loading: @escaping () -> LoadingContent,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder empty: @escaping () -> EmptyContent,
        @ViewBuilder failed: @escaping (Failure) -> FailedContent,
    ) {
        self.state = state
        loadingContent = loading
        self.content = content
        emptyContent = empty
        failedContent = failed
    }

    public var body: some View {
        switch state {
        case .idle:
            loadingContent()

        case .loading:
            loadingContent()

        case let .loaded(value):
            content(value)

        case .empty:
            emptyContent()

        case let .failed(failure):
            failedContent(failure)
        }
    }
}
