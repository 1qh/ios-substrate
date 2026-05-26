/// Product-neutral lifecycle state for fetch-on-mount and async-load surfaces.
///
/// Product apps own the failure type, empty-state copy, retry copy, and rendering.
/// Substrate owns only the state machine shape so screens do not recreate
/// `isLoading` + `error` + optional-value combinations.
public enum LoadState<Value: Sendable, Failure: Sendable>: Sendable {
    case empty
    case failed(Failure)
    case idle
    case loaded(Value)
    case loading

    public var value: Value? {
        if case let .loaded(wrapped) = self {
            return wrapped
        }
        return nil
    }
}
