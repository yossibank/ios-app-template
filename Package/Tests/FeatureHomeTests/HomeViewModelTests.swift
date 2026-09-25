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

    @Test("追加取得が一部失敗したら知らせを立て、続きがあることは残す")
    func fetchMoreSurfacesItsFailure() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            degraded(.offline, ["a"])
        )

        _ = try await model.fetch()
        let more = try await model.fetchMore()

        #expect(model.viewState.notice == .offline, "追加取得の失敗が握り潰されている")

        guard case .more? = more else {
            Issue.record("失敗しただけで続きが無いことにされている")
            return
        }
    }

    @Test("閉じると共通コアも閉じる")
    func closeReachesTheSharedCore() {
        let stub = StubListing([loaded(["a"])])
        let model = HomeViewModel(dependency: .init(listing: stub))

        model.close()

        #expect(stub.closed)
    }

    @Test("画面を手放すと共通コアも閉じる")
    func releasingTheModelClosesTheSharedCore() {
        let stub = StubListing([loaded(["a"])])
        var model: HomeViewModel? = HomeViewModel(dependency: .init(listing: stub))

        #expect(model != nil)
        #expect(stub.closed == false, "手放す前に閉じている")

        model = nil

        #expect(stub.closed, "手放しても共通コアが開いたまま")
    }

    @Test("最初の取得の失敗はそのまま失敗として投げる")
    func fetchThrowsTheFailure() async throws {
        let failure = try await #require(throws: FetchFailure.self) {
            _ = try await model(.failed(.timeout)).fetch()
        }

        #expect(failure == .timeout)
    }

    @Test("続きの取得がすべて失敗したら知らせを立て、一覧には何も積まない")
    func fetchMoreFailureRaisesANotice() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            .failed(.offline)
        )

        _ = try await model.fetch()
        let more = try await model.fetchMore()

        #expect(more == nil)
        #expect(model.viewState.notice == .offline)
    }

    @Test("捨てられた結果は続きとして積まない")
    func staleResultsAreNotAppended() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            .stale
        )

        _ = try await model.fetch()
        let more = try await model.fetchMore()

        #expect(more == nil, "捨てられた結果が続きとして積まれている")
    }

    private func model(_ pages: PokemonListPage...) -> HomeViewModel {
        HomeViewModel(dependency: .init(listing: StubListing(pages)))
    }

    private func loaded(_ names: [String], hasMore: Bool = false) -> PokemonListPage {
        .loaded(snapshot(names, hasMore: hasMore))
    }

    private func degraded(_ failure: FetchFailure, _ names: [String]) -> PokemonListPage {
        .degraded(snapshot(names, hasMore: true), failure)
    }

    private func snapshot(_ names: [String], hasMore: Bool) -> PokemonListSnapshot {
        PokemonListSnapshot(
            pokemon: names.enumerated().map { index, name in
                .fixture(id: index + 1, name: name)
            },
            hasMore: hasMore,
            total: 1351
        )
    }

    private func fetchMoreGenerically<Model: ScreenViewModel>(
        _ model: Model
    ) async throws -> FetchMore<Model.Value>? {
        try await model.fetchMore()
    }
}

private final class StubListing: PokemonListing, @unchecked Sendable {
    private(set) var closed = false

    private let pages: [PokemonListPage]
    private var index = 0

    init(_ pages: [PokemonListPage]) {
        self.pages = pages
    }

    func reload() async -> PokemonListPage {
        index = 0
        return next()
    }

    func loadNext() async -> PokemonListPage {
        next()
    }

    func close() {
        closed = true
    }

    private func next() -> PokemonListPage {
        defer { index += 1 }
        return pages[min(index, pages.count - 1)]
    }
}
