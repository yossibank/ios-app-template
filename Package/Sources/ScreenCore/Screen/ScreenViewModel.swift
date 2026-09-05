@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var fetchState: FetchState<Value> { get }

    func fetch() async throws -> Value
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
}
