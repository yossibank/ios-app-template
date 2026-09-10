@testable import FeatureHome
import ScreenCore
import SharedCore
import Testing

private struct StubApi: PokemonFetching, @unchecked Sendable {
    let result: any PokemonListResult

    func fetchPage(limit: Int32, offset: Int32) async throws -> any PokemonListResult {
        result
    }
}

@MainActor
struct HomeViewModelTests {
    @Test("取得に成功したら一覧になる")
    func mapsLoadedResult() async throws {
        let pokemon = try await model(
            returning: PokemonListResultLoaded(
                pokemon: [PokemonSummary(name: "pikachu", url: "u")],
                hasMore: false
            )
        ).fetch()

        #expect(pokemon.map(\.name) == ["pikachu"])
    }

    @Test("接続できないときは再試行できる失敗になる")
    func offlineCanBeRetried() async throws {
        let failure = try await failure(from: PokemonListResultFailedOffline.shared)

        #expect(failure.canRetry)
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverFailureCarriesStatusCode() async throws {
        let failure = try await failure(from: PokemonListResultFailedServer(statusCode: 503))

        #expect(failure.message.contains("503"))
        #expect(failure.canRetry)
    }

    @Test("解釈できない応答は再試行できない失敗になる")
    func unreadableBodyCannotBeRetried() async throws {
        let failure = try await failure(from: PokemonListResultFailedUnexpected.shared)

        #expect(!failure.canRetry)
    }
}

private extension HomeViewModelTests {
    func model(returning result: any PokemonListResult) -> HomeViewModel {
        HomeViewModel(dependency: .init(api: StubApi(result: result)))
    }

    func failure(from result: any PokemonListResult) async throws -> FetchFailure {
        try await #require(throws: FetchFailure.self) {
            _ = try await model(returning: result).fetch()
        }
    }
}
