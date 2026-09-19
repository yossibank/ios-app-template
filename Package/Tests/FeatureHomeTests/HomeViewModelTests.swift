@testable import FeatureHome
import ScreenCore
import SharedCore
import Testing

private final class StubPaging: PokemonPaging, @unchecked Sendable {
    private let pages: [any PokemonListResult]
    private var index = 0

    private(set) var calls = 0

    init(_ pages: [any PokemonListResult]) {
        self.pages = pages
    }

    func loadNext() async throws -> any PokemonListResult {
        calls += 1
        defer { index += 1 }
        return pages[min(index, pages.count - 1)]
    }

    func reset() async throws {
        index = 0
    }
}

private func loaded(
    _ names: [String],
    hasMore: Bool = false
) -> any PokemonListResult {
    PokemonListResultLoaded(
        pokemon: names.map { PokemonSummary(name: $0, url: "u/\($0)") },
        hasMore: hasMore
    )
}

/// ジェネリック文脈から呼ぶ。プロトコル要求になっていなければ既定の nil が返る。
@MainActor
private func fetchMoreGenerically<Model: ScreenViewModel>(
    _ model: Model
) async throws -> Model.Value? {
    try await model.fetchMore()
}

@MainActor
struct HomeViewModelTests {
    @Test("取得に成功したら一覧になる")
    func mapsLoadedResult() async throws {
        let pokemon = try await model(loaded(["pikachu"])).fetch()

        #expect(pokemon.map(\.name) == ["pikachu"])
    }

    @Test("続きを読むと一覧が伸びる")
    func fetchMoreAppends() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            loaded(["a", "b"])
        )

        _ = try await model.fetch()
        let more = try await model.fetchMore()

        #expect(more?.map(\.name) == ["a", "b"])
        #expect(model.viewState.hasMore == false)
    }

    @Test("終端では続きを読まない")
    func fetchMoreStopsAtTheEnd() async throws {
        let paging = StubPaging([loaded(["a"])])
        let model = HomeViewModel(dependency: .init(paging: paging))

        _ = try await model.fetch()
        let callsAtEnd = paging.calls
        let more = try await model.fetchMore()

        #expect(more == nil)
        #expect(paging.calls == callsAtEnd)
    }

    @Test("ジェネリック文脈からでも画面の実装が呼ばれる")
    func fetchMoreDispatchesToTheScreen() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            loaded(["a", "b"])
        )

        _ = try await model.fetch()
        let more = try await fetchMoreGenerically(model)

        #expect(more?.map(\.name) == ["a", "b"], "プロトコル既定の nil が返っている")
    }

    @Test("接続できないときは再試行できる失敗になる")
    func offlineCanBeRetried() async throws {
        #expect(try await failure(from: PokemonListResultFailedOffline.shared).canRetry)
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverFailureCarriesStatusCode() async throws {
        let failure = try await failure(from: PokemonListResultFailedServer(statusCode: 503))

        #expect(failure.message.contains("503"))
        #expect(failure.canRetry)
    }

    @Test("解釈できない応答は再試行できない失敗になる")
    func unreadableBodyCannotBeRetried() async throws {
        #expect(try await !failure(from: PokemonListResultFailedUnexpected.shared).canRetry)
    }

    private func model(_ pages: any PokemonListResult...) -> HomeViewModel {
        HomeViewModel(dependency: .init(paging: StubPaging(pages)))
    }

    private func failure(from result: any PokemonListResult) async throws -> FetchFailure {
        try await #require(throws: FetchFailure.self) {
            _ = try await model(result).fetch()
        }
    }
}
