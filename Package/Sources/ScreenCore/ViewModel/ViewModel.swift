import Observation

@MainActor
public protocol ViewModel: AnyObject, Observable {
    associatedtype State: ViewState = EmptyViewState

    var viewState: State { get }
}

public extension ViewModel where State == EmptyViewState {
    var viewState: EmptyViewState {
        .default
    }
}
