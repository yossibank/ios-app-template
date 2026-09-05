import Observation

@MainActor
public protocol ViewModel: AnyObject, Observable {
    associatedtype Dependency
    associatedtype State: ViewState = EmptyViewState

    var state: State { get }
    var dependency: Dependency { get }

    init(dependency: Dependency)
}

public extension ViewModel where State == EmptyViewState {
    var state: EmptyViewState {
        .shared
    }
}
