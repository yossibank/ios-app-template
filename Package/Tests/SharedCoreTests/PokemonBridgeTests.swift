import Foundation
import ScreenCore
import Shared
@testable import SharedCore
import Testing

struct PokemonBridgeTests {
    @Test("一覧の行が id・名前・画像の URL になる")
    func entriesBecomePokemon() {
        let pokemon = Pokemon(entry(id: 25, name: "pikachu"))

        #expect(pokemon.id == 25)
        #expect(pokemon.name == "pikachu")
        #expect(pokemon.artwork == URL(string: "https://img.example/25.png"))
    }

    @Test("失敗の種類が共通の文言になる")
    func failuresBecomeTheSharedMessages() {
        #expect(FetchFailure(ApiFailureOffline.shared) == .offline)
        #expect(FetchFailure(ApiFailureTimeout.shared) == .timeout)
        #expect(FetchFailure(ApiFailureUnreadable.shared) == .unreadable)
        #expect(FetchFailure(ApiFailureClosed.shared) == .unexpected(canRetry: false))
        #expect(FetchFailure(ApiFailureServer(statusCode: 503)).message.contains("503"))
    }

    @Test("再試行できるかは共通コアの判断をそのまま使う")
    func retryabilityComesFromTheSharedCore() {
        #expect(FetchFailure(ApiFailureOffline.shared).canRetry)
        #expect(FetchFailure(ApiFailureTimeout.shared).canRetry)
        #expect(FetchFailure(ApiFailureServer(statusCode: 503)).canRetry)
        #expect(FetchFailure(ApiFailureServer(statusCode: 429)).canRetry)
        #expect(!FetchFailure(ApiFailureServer(statusCode: 404)).canRetry)
        #expect(!FetchFailure(ApiFailureUnreadable.shared).canRetry)
        #expect(!FetchFailure(ApiFailureClosed.shared).canRetry)
    }

    @Test("読み込めたページが snapshot になる")
    func loadedResultsBecomeASnapshot() {
        let page = PokemonListPage(
            PokemonListResultLoaded(
                pokemon: [entry(id: 1, name: "bulbasaur")],
                hasMore: true,
                total: 1351,
                failure: nil
            )
        )

        guard case let .loaded(snapshot) = page else {
            Issue.record("読み込めたページになっていない")
            return
        }

        #expect(snapshot.pokemon.map(\.name) == ["bulbasaur"])
        #expect(snapshot.hasMore)
        #expect(snapshot.total == 1351)
    }

    @Test("一部だけ失敗したページは理由を連れてくる")
    func degradedResultsCarryTheirFailure() {
        let page = PokemonListPage(
            PokemonListResultLoaded(
                pokemon: [entry(id: 1, name: "bulbasaur")],
                hasMore: true,
                total: 1351,
                failure: ApiFailureOffline.shared
            )
        )

        guard case let .degraded(snapshot, failure) = page else {
            Issue.record("一部だけ失敗したページになっていない")
            return
        }

        #expect(snapshot.pokemon.count == 1)
        #expect(failure == .offline)
    }

    @Test("全部失敗したページは失敗になる")
    func failedResultsBecomeAFailure() {
        let page = PokemonListPage(PokemonListResultFailed(failure: ApiFailureTimeout.shared))

        #expect(page == .failed(.timeout))
    }

    @Test("捨てられた結果はそのまま捨てられた結果になる")
    func staleResultsStayStale() {
        #expect(PokemonListPage(PokemonListResultStale.shared) == .stale)
    }

    private func entry(id: Int32, name: String) -> PokemonEntry {
        PokemonEntry(id: id, name: name, imageUrl: "https://img.example/\(id).png")
    }
}
