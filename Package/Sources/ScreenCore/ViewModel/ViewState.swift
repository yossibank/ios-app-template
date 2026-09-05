import Observation

@MainActor
public protocol ViewState: AnyObject, Observable {
    init()
}

@Observable
public final class EmptyViewState: ViewState {
    static let `default` = EmptyViewState()

    public init() {}
}
