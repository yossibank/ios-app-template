@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var fetchState: FetchState<Value> { get }

    func fetch() async throws(FetchFailure) -> Value
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>?
    func update() async throws(FetchFailure) -> Value?
}

public extension ScreenViewModel {
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>? {
        nil
    }

    func update() async throws(FetchFailure) -> Value? {
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

        case .loadMore:
            fetchState.loadMore { () async throws(FetchFailure) -> FetchMore<Value>? in
                try await self.fetchMore()
            }

        case .update:
            fetchState.update { () async throws(FetchFailure) -> Value? in
                try await self.update()
            }
        }
    }

    func refresh() async {
        await fetchState.refresh { () async throws(FetchFailure) -> Value in
            try await self.fetch()
        }
    }
}
