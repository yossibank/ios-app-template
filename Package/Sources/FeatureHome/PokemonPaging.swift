import ScreenCore
import SharedCore

protocol PokemonPaging: Sendable {
    func loadNext() async throws(FetchFailure) -> any PokemonListResult
    func reset() async throws(FetchFailure)
}

struct SharedPokemonPaging: PokemonPaging {
    private nonisolated(unsafe) let pager = PokemonPager()

    func loadNext() async throws(FetchFailure) -> any PokemonListResult {
        try await unexpected {
            try await pager.loadNext()
        }
    }

    func reset() async throws(FetchFailure) {
        try await unexpected {
            try await pager.reset()
        }
    }
}

private extension SharedPokemonPaging {
    func unexpected<T>(
        _ operation: () async throws -> T
    ) async throws(FetchFailure) -> T {
        do {
            return try await operation()
        } catch {
            throw FetchFailure(HomeStrings.unexpected)
        }
    }
}
