import Foundation
import Shared
@testable import SharedCore
import Testing

struct PokemonBridgeTests {
    @Test("詳細を引けた行は profile を持つ")
    func loadedEntriesCarryTheirProfile() {
        let pokemon = Pokemon(
            PokemonEntry(
                id: 25,
                name: "pikachu",
                detail: PokemonEntryDetailLoaded(
                    imageUrl: "https://img.example/artwork/25.png",
                    types: [.electric],
                    baseStats: [Shared.PokemonBaseStat(kind: .speed, value: 90)]
                )
            )
        )

        #expect(pokemon.id == 25)
        #expect(pokemon.profile?.types == [.electric])
        #expect(pokemon.profile?.baseStats == [PokemonBaseStat(kind: .speed, value: 90)])
        #expect(pokemon.profile?.totalBaseStat == 90)
    }

    @Test("詳細を引けなかった行は profile が無い")
    func missingEntriesHaveNoProfile() {
        let pokemon = Pokemon(
            PokemonEntry(
                id: 132,
                name: "ditto",
                detail: PokemonEntryDetailMissing(failure: PokemonFailureServer(statusCode: 500))
            )
        )

        #expect(pokemon.profile == nil)
    }

    @Test("共通コアが選んだ画像が URL になる")
    func theImageBecomesAURL() {
        let image = "https://img.example/art/1.png"

        #expect(profile(image: image)?.artwork == URL(string: image))
    }

    @Test("画像が無ければ URL は無い")
    func noImageMeansNoURL() {
        #expect(profile(image: nil)?.artwork == nil)
    }

    @Test("合計は各能力の和になる")
    func totalIsTheSumOfTheStats() {
        let stats = [
            Shared.PokemonBaseStat(kind: .hp, value: 45),
            Shared.PokemonBaseStat(kind: .attack, value: 49)
        ]

        #expect(profile(image: nil, baseStats: stats)?.totalBaseStat == 94)
    }

    @Test("失敗の種類が共通コアから引き継がれる")
    func failureReasonsAreCarriedOver() {
        #expect(PokemonLoadFailure(PokemonFailureOffline.shared).reason == .offline)
        #expect(PokemonLoadFailure(PokemonFailureTimeout.shared).reason == .timeout)
        #expect(PokemonLoadFailure(PokemonFailureServer(statusCode: 503)).reason == .server(statusCode: 503))
        #expect(PokemonLoadFailure(PokemonFailureUnexpected.shared).reason == .unreadable)
        #expect(PokemonLoadFailure(PokemonFailureClosed.shared).reason == .closed)
    }

    @Test("再試行できるかは共通コアの判断をそのまま使う")
    func retryabilityComesFromTheSharedCore() {
        #expect(PokemonLoadFailure(PokemonFailureOffline.shared).canRetry)
        #expect(PokemonLoadFailure(PokemonFailureTimeout.shared).canRetry)
        #expect(PokemonLoadFailure(PokemonFailureServer(statusCode: 503)).canRetry)
        #expect(PokemonLoadFailure(PokemonFailureServer(statusCode: 429)).canRetry)
        #expect(!PokemonLoadFailure(PokemonFailureServer(statusCode: 404)).canRetry)
        #expect(!PokemonLoadFailure(PokemonFailureUnexpected.shared).canRetry)
        #expect(!PokemonLoadFailure(PokemonFailureClosed.shared).canRetry)
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
                failure: PokemonFailureOffline.shared
            )
        )

        guard case let .degraded(snapshot, failure) = page else {
            Issue.record("一部だけ失敗したページになっていない")
            return
        }

        #expect(snapshot.pokemon.count == 1)
        #expect(failure.reason == .offline)
    }

    @Test("全部失敗したページは失敗になる")
    func failedResultsBecomeAFailure() {
        let page = PokemonListPage(PokemonListResultFailed(failure: PokemonFailureTimeout.shared))

        guard case let .failed(failure) = page else {
            Issue.record("失敗になっていない")
            return
        }

        #expect(failure.reason == .timeout)
    }

    @Test("捨てられた結果はそのまま捨てられた結果になる")
    func staleResultsStayStale() {
        #expect(PokemonListPage(PokemonListResultStale.shared) == .stale)
    }

    @Test("詳細を引けなかった件数が数えられる")
    func incompleteRowsAreCounted() {
        let snapshot = PokemonListSnapshot(
            pokemon: [
                Pokemon(id: 1, name: "bulbasaur", profile: nil),
                Pokemon(id: 4, name: "charmander", profile: PokemonProfile(artwork: nil, types: [], baseStats: []))
            ],
            hasMore: false,
            total: 2
        )

        #expect(snapshot.incompleteCount == 1)
    }

    @Test("先読みの距離は共通コアから引く")
    func prefetchDistanceComesFromTheSharedCore() {
        #expect(PokemonList.prefetchDistance == Int(PokemonPager.companion.PREFETCH_DISTANCE))
    }

    private func entry(id: Int32, name: String) -> PokemonEntry {
        PokemonEntry(
            id: id,
            name: name,
            detail: PokemonEntryDetailLoaded(
                imageUrl: nil,
                types: [.grass],
                baseStats: []
            )
        )
    }

    private func profile(
        image: String?,
        baseStats: [Shared.PokemonBaseStat] = []
    ) -> PokemonProfile? {
        Pokemon(
            PokemonEntry(
                id: 1,
                name: "bulbasaur",
                detail: PokemonEntryDetailLoaded(
                    imageUrl: image,
                    types: [],
                    baseStats: baseStats
                )
            )
        ).profile
    }
}
