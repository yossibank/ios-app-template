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

        #expect(model.viewState.notice != nil, "追加取得の失敗が握り潰されている")
        #expect(model.viewState.notice?.retry == .loadMore, "続きの失敗なのに続きを読み直さない")

        guard case .more? = more else {
            Issue.record("失敗しただけで続きが無いことにされている")
            return
        }
    }

    @Test("詳細を取れなかった件数が出る")
    func incompleteRowsAreCounted() async throws {
        let model = model(loaded(["a", "b"], hasDetail: false))

        _ = try await model.fetch()

        #expect(model.viewState.incompleteCount == 2)
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

    @Test("接続できないときは再試行できる失敗になる")
    func offlineCanBeRetried() async throws {
        #expect(try await failure(from: failed(.offline)).canRetry)
    }

    @Test("応答が遅いときは接続断とは別の文言になる")
    func timeoutIsNotReportedAsOffline() async throws {
        let failure = try await failure(from: failed(.timeout))

        #expect(failure.message == HomeStrings.timeout)
        #expect(failure.message != HomeStrings.offline)
        #expect(failure.canRetry)
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverFailureCarriesStatusCode() async throws {
        let failure = try await failure(from: failed(.server(statusCode: 503)))

        #expect(failure.message.contains("503"))
        #expect(failure.canRetry)
    }

    @Test("解釈できない応答は再試行できない失敗になる")
    func unreadableBodyCannotBeRetried() async throws {
        #expect(try await !failure(from: failed(.unreadable, canRetry: false)).canRetry)
    }

    @Test("共通コアの呼び出しが中断されたら予期しないエラーとして出る")
    func interruptedCallsAreReported() async throws {
        let failure = try await failure(from: failed(.interrupted))

        #expect(failure.message == HomeStrings.unexpected)
    }

    @Test("詳細だけを取り直すとページを読み直さずに埋まる")
    func repairFillsTheMissingRows() async throws {
        let stub = StubListing(
            [loaded(["a", "b"], hasDetail: false)],
            repaired: loaded(["a", "b"])
        )
        let model = HomeViewModel(dependency: .init(listing: stub))

        _ = try await model.fetch()

        #expect(model.viewState.incompleteCount == 2)

        let repaired = try await model.fetchRepaired()

        #expect(repaired?.map(\.name) == ["a", "b"])
        #expect(model.viewState.incompleteCount == 0, "取り直しても欠けたままになっている")
        #expect(stub.repairCalls == 1)
        #expect(stub.calls == 1, "詳細の取り直しでページを読み直している")
    }

    @Test("取り直しても埋まらなければ理由を知らせる")
    func repairReportsWhyNothingChanged() async throws {
        let stub = StubListing(
            [loaded(["a"], hasDetail: false)],
            repaired: degraded(.offline, ["a"])
        )
        let model = HomeViewModel(dependency: .init(listing: stub))

        _ = try await model.fetch()
        _ = try await model.fetchRepaired()

        #expect(model.viewState.notice != nil, "取り直しの失敗が握り潰されている")
        #expect(model.viewState.notice?.retry == .repair, "取り直しの失敗なのに続きを読もうとしている")
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

    private func failure(from page: PokemonListPage) async throws -> FetchFailure {
        try await #require(throws: FetchFailure.self) {
            _ = try await model(page).fetch()
        }
    }

    private func loaded(
        _ names: [String],
        hasMore: Bool = false,
        hasDetail: Bool = true
    ) -> PokemonListPage {
        .loaded(snapshot(names, hasMore: hasMore, hasDetail: hasDetail))
    }

    private func degraded(
        _ reason: PokemonLoadFailure.Reason,
        _ names: [String]
    ) -> PokemonListPage {
        .degraded(
            snapshot(names, hasMore: true, hasDetail: true),
            PokemonLoadFailure(reason: reason, canRetry: true)
        )
    }

    private func failed(
        _ reason: PokemonLoadFailure.Reason,
        canRetry: Bool = true
    ) -> PokemonListPage {
        .failed(PokemonLoadFailure(reason: reason, canRetry: canRetry))
    }

    private func snapshot(
        _ names: [String],
        hasMore: Bool,
        hasDetail: Bool
    ) -> PokemonListSnapshot {
        PokemonListSnapshot(
            pokemon: names.enumerated().map { index, name in
                hasDetail
                    ? .fixture(id: index + 1, name: name)
                    : .incomplete(id: index + 1, name: name)
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
    private let pages: [PokemonListPage]
    private let repaired: PokemonListPage?
    private var index = 0

    private(set) var calls = 0

    private(set) var repairCalls = 0

    private(set) var closed = false

    init(_ pages: [PokemonListPage], repaired: PokemonListPage? = nil) {
        self.pages = pages
        self.repaired = repaired
    }

    func reload() async -> PokemonListPage {
        index = 0
        return next()
    }

    func loadNext() async -> PokemonListPage {
        next()
    }

    func retryMissingDetails() async -> PokemonListPage {
        repairCalls += 1
        return repaired ?? .loaded(PokemonListSnapshot(pokemon: [], hasMore: false, total: 0))
    }

    func close() {
        closed = true
    }

    private func next() -> PokemonListPage {
        calls += 1
        defer { index += 1 }
        return pages[min(index, pages.count - 1)]
    }
}
