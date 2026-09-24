@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var fetchState: FetchState<Value> { get }

    func fetch() async throws(FetchFailure) -> Value
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>?
    func fetchRefilled() async throws(FetchFailure) -> Value?
}

public extension ScreenViewModel {
    func fetchMore() async throws(FetchFailure) -> FetchMore<Value>? {
        nil
    }

    func fetchRefilled() async throws(FetchFailure) -> Value? {
        nil
    }
}

extension ScreenViewModel {
    func request(_ operation: FetchOperation) {
        fetchState.request(operation)
    }

    func run(_ operation: FetchOperation) async {
        switch operation {
        case .reload:
            await fetchState.runReload { () async throws(FetchFailure) -> Value in
                try await fetch()
            }

        case .loadMore:
            await fetchState.runMore { () async throws(FetchFailure) -> FetchMore<Value>? in
                try await fetchMore()
            }

        case .refill:
            await fetchState.runRefill { () async throws(FetchFailure) -> Value? in
                try await fetchRefilled()
            }
        }
    }

    func refresh() async {
        await fetchState.runRefresh { () async throws(FetchFailure) -> Value in
            try await fetch()
        }
    }
}
