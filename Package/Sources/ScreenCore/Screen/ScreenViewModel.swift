@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var fetchState: FetchState<Value> { get }

    func fetch() async throws -> Value
    func fetchMore() async throws -> Value?
}

public extension ScreenViewModel {
    func fetchMore() async throws -> Value? {
        nil
    }
}

extension ScreenViewModel {
    func load() async {
        await fetchState.run {
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
        await fetchState.runMore {
            try await fetchMore()
        }
    }
}
