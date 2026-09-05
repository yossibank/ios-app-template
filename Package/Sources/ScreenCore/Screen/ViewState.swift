import Observation

@MainActor
public protocol ViewState: AnyObject, Observable {
    init()
}

@Observable
public final class EmptyViewState: ViewState {
    public static let shared = EmptyViewState()

    public init() {}
}
