import Observation

@MainActor
public protocol ViewModel: AnyObject, Observable {
    associatedtype Dependency
    associatedtype State: ViewState = EmptyViewState

    var viewState: State { get }
    var dependency: Dependency { get }

    init()
}

public extension ViewModel where State == EmptyViewState {
    var viewState: EmptyViewState {
        .default
    }
}
