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
    @Test
    func `maps loaded result to pokemon`() async throws {
        let model = HomeViewModel(
            dependency: .init(
                api: StubApi(
                    result: PokemonListResultLoaded(
                        pokemon: [PokemonSummary(name: "pikachu", url: "u")],
                        hasMore: false
                    )
                )
            )
        )

        let pokemon = try await model.fetch()

        #expect(pokemon.map(\.name) == ["pikachu"])
    }

    @Test
    func `throws fetch failure when result failed`() async {
        let model = HomeViewModel(
            dependency: .init(
                api: StubApi(result: PokemonListResultFailed(message: "圏外です"))
            )
        )

        await #expect(throws: FetchFailure.self) {
            _ = try await model.fetch()
        }
    }
}
