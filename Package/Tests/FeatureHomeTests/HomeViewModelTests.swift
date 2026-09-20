@testable import FeatureHome
import ScreenCore
import SharedCore
import Testing

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

        #expect(more?.value.map(\.name) == ["a", "b"])
    }

    @Test("最後のページは終端として返す")
    func theLastPageIsMarkedAsLast() async throws {
        let model = model(loaded(["a"]))

        _ = try await model.fetch()
        let more = try await model.fetchMore()

        guard case .last? = more else {
            Issue.record("終端になっていない")
            return
        }
    }

    @Test("ジェネリック文脈からでも画面の実装が呼ばれる")
    func fetchMoreDispatchesToTheScreen() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            loaded(["a", "b"])
        )

        _ = try await model.fetch()
        let more = try await fetchMoreGenerically(model)

        #expect(more?.value.map(\.name) == ["a", "b"], "プロトコル既定の nil が返っている")
    }

    @Test("接続できないときは再試行できる失敗になる")
    func offlineCanBeRetried() async throws {
        #expect(try await failure(from: failed(PokemonListFailureOffline.shared)).canRetry)
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverFailureCarriesStatusCode() async throws {
        let failure = try await failure(from: failed(PokemonListFailureServer(statusCode: 503)))

        #expect(failure.message.contains("503"))
        #expect(failure.canRetry)
    }

    @Test("解釈できない応答は再試行できない失敗になる")
    func unreadableBodyCannotBeRetried() async throws {
        #expect(try await !failure(from: failed(PokemonListFailureUnexpected.shared)).canRetry)
    }

    private func model(_ pages: PokemonListResult...) -> HomeViewModel {
        HomeViewModel(dependency: .init(paging: StubPaging(pages)))
    }

    private func failure(from result: PokemonListResult) async throws -> FetchFailure {
        try await #require(throws: FetchFailure.self) {
            _ = try await model(result).fetch()
        }
    }

    private func loaded(
        _ names: [String],
        hasMore: Bool = false
    ) -> PokemonListResult {
        PokemonListResult(
            pokemon: entries(names),
            hasMore: hasMore,
            failure: nil
        )
    }

    private func failed(
        _ failure: any PokemonListFailure,
        _ names: [String] = []
    ) -> PokemonListResult {
        PokemonListResult(
            pokemon: entries(names),
            hasMore: true,
            failure: failure
        )
    }

    private func entries(_ names: [String]) -> [PokemonEntry] {
        names.enumerated().map { index, name in
            PokemonEntry(
                id: Int32(index + 1),
                name: name,
                japaneseName: nil,
                spriteUrl: "https://img.example/\(index + 1).png",
                types: [.grass],
                baseStats: [PokemonBaseStat(kind: .hp, value: 45)]
            )
        }
    }

    /// ジェネリック文脈から呼ぶ。プロトコル要求になっていなければ既定の nil が返る。
    private func fetchMoreGenerically<Model: ScreenViewModel>(
        _ model: Model
    ) async throws -> FetchMore<Model.Value>? {
        try await model.fetchMore()
    }
}

private final class StubPaging: PokemonPaging {
    private nonisolated(unsafe) let pages: [PokemonListResult]
    private nonisolated(unsafe) var index = 0

    private(set) nonisolated(unsafe) var calls = 0

    init(_ pages: [PokemonListResult]) {
        self.pages = pages
    }

    func loadNext() async throws -> PokemonListResult {
        calls += 1
        defer { index += 1 }
        return pages[min(index, pages.count - 1)]
    }

    func reset() async throws {
        index = 0
    }
}
