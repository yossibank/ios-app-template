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
    func start() {
        guard case .idle = fetchState.phase else {
            return
        }

        request(.reload)
    }

    func request(_ operation: FetchOperation) {
        switch operation {
        case .reload:
            fetchState.reload { () async throws(FetchFailure) -> Value in
                try await self.fetch()
            }

        case .refresh:
            fetchState.refresh { () async throws(FetchFailure) -> Value in
                try await self.fetch()
            }

        case .loadMore:
            fetchState.loadMore { () async throws(FetchFailure) -> FetchMore<Value>? in
                try await self.fetchMore()
            }
        }
    }

    func refresh() async {
        await fetchState.refresh { () async throws(FetchFailure) -> Value in
            try await self.fetch()
        }?.value
    }
}
