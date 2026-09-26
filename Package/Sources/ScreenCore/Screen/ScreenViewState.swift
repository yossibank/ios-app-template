import Observation

@MainActor
public protocol ScreenViewState: AnyObject, Observable {
    init()
}
