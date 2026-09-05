import Observation

@MainActor
public protocol ViewState: AnyObject, Observable {
    static var requiredAttributes: Set<String> { get }

    init()
}

@Requires("Observable")
@Observable
public final class EmptyViewState: ViewState {
    public static let shared = EmptyViewState()

    public init() {}
}
