@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var fetchState: FetchState<Value> { get }

    func fetch() async throws(FetchFailure) -> Value
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>?
}

public extension ScreenViewModel {
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>? {
        nil
    }
}

extension ScreenViewModel {
    func load() async {
        await fetchState.run { () async throws(FetchFailure) -> Value in
            try await fetch()
        }
    }

    func reload() {
        fetchState.requestReload()
    }

    func requestLoadMore() {
        fetchState.requestLoadMore()
    }

    func loadMore() async {
        await fetchState.runMore { () async throws(FetchFailure) -> FetchMore<Value>? in
            try await fetchMore()
        }
    }
}
