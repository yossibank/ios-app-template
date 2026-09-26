import Observation

@MainActor
public protocol ScreenViewModel: AnyObject, Observable {
    associatedtype State: ScreenViewState
    associatedtype Value

    var viewState: State { get }
    var fetchState: FetchState<Value> { get }

    func fetch() async throws(FetchFailure) -> Value
    func fetchMore(after current: Value) async throws(FetchFailure) -> FetchMore<Value>
}

public extension ScreenViewModel {
    func fetchMore(after _: Value) async throws(FetchFailure) -> FetchMore<Value> {
        .unchanged
    }
}

extension ScreenViewModel {
    func start() {
        guard case .idle = fetchState.phase else {
            return
        }

        reload()
    }

    func reload() {
        fetchState.reload(fetch)
    }

    func refresh() async {
        await fetchState.refresh(fetch)?.value
    }

    func loadMore() {
        fetchState.loadMore(fetchMore(after:))
    }
}
