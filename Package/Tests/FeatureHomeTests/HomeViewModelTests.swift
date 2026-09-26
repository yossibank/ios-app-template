@testable import FeatureHome
@testable import ScreenCore
import SharedCore
import Testing

@MainActor
struct HomeViewModelTests {
    @Test("取得に成功したら一覧になる")
    func mapsLoadedResult() async throws {
        let list = try await model(loaded(["pikachu"])).fetch()

        #expect(list.pokemon.map(\.name) == ["pikachu"])
        #expect(list.total == 1351)
        #expect(list.notice == nil)
    }

    @Test("続きを読むと一覧が伸びる")
    func fetchMoreAppends() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            loaded(["a", "b"])
        )

        let first = try await model.fetch()
        let more = try await model.fetchMore(after: first)

        #expect(more.value?.pokemon.map(\.name) == ["a", "b"])
    }

    @Test("最後のページは終端として返す")
    func theLastPageIsMarkedAsLast() async throws {
        let model = model(loaded(["a"]))

        let first = try await model.fetch()
        let more = try await model.fetchMore(after: first)

        guard case .last = more else {
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

        let first = try await model.fetch()
        let more = try await fetchMoreGenerically(model, after: first)

        #expect(more.value?.pokemon.map(\.name) == ["a", "b"], "プロトコル既定の .unchanged が返っている")
    }

    @Test("追加取得が一部失敗したら知らせを立て、続きがあることは残す")
    func fetchMoreSurfacesItsFailure() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            degraded(.offline, ["a"])
        )

        let first = try await model.fetch()
        let more = try await model.fetchMore(after: first)

        #expect(more.value?.notice == .offline, "追加取得の失敗が握り潰されている")

        guard case .more = more else {
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

    @Test("続きの取得がすべて失敗したら、読み込めている分はそのままに知らせを載せる")
    func fetchMoreFailureRaisesANotice() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            .failed(.offline)
        )

        let first = try await model.fetch()
        let more = try await model.fetchMore(after: first)

        guard case let .more(list) = more else {
            Issue.record("失敗しただけで続きが無いことにされている")
            return
        }

        #expect(list.pokemon.map(\.name) == ["a"], "失敗したのに一覧が変わっている")
        #expect(list.notice == .offline)
    }

    @Test("捨てられた結果は続きとして積まない")
    func staleResultsAreNotAppended() async throws {
        let model = model(
            loaded(["a"], hasMore: true),
            .stale
        )

        let first = try await model.fetch()
        let more = try await model.fetchMore(after: first)

        guard case .unchanged = more else {
            Issue.record("捨てられた結果が続きとして積まれている")
            return
        }
    }

    @Test("再取得で置き換えられた続きの取得は、知らせを立てない")
    func replacedLoadMoreDoesNotRaiseANotice() async {
        let listing = GatedListing(
            reloads: [loaded(["a"], hasMore: true), loaded(["x"])],
            next: degraded(.offline, ["a", "b"])
        )
        let model = HomeViewModel(dependency: .init(listing: listing))

        await model.fetchState.reload(model.fetch)?.value
        let more = model.fetchState.loadMore(model.fetchMore(after:))
        await listing.gate.waitUntilEntered()

        await model.fetchState.reload(model.fetch)?.value
        listing.gate.open()
        await more?.value

        guard case let .loaded(list) = model.fetchState.phase else {
            Issue.record("再取得の結果が出ていない")
            return
        }

        #expect(list.pokemon.map(\.name) == ["x"])
        #expect(list.notice == nil, "置き換えられた続きの取得が知らせを立てている")
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
        _ model: Model,
        after current: Model.Value
    ) async throws -> FetchMore<Model.Value> {
        try await model.fetchMore(after: current)
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

private final class GatedListing: PokemonListing, @unchecked Sendable {
    let gate = ListingGate()

    private var reloads: [PokemonListPage]
    private let next: PokemonListPage

    init(reloads: [PokemonListPage], next: PokemonListPage) {
        self.reloads = reloads
        self.next = next
    }

    func reload() async -> PokemonListPage {
        reloads.removeFirst()
    }

    func loadNext() async -> PokemonListPage {
        await gate.wait()
        return next
    }

    func close() {}
}

private final class ListingGate: @unchecked Sendable {
    private var continuation: CheckedContinuation<Void, Never>?
    private var entered = false

    func wait() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            entered = true
        }
    }

    func waitUntilEntered() async {
        while !entered {
            await Task.yield()
        }
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }
}
