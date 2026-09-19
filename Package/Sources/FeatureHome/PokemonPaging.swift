import SharedCore

protocol PokemonPaging: Sendable {
    func loadNext() async throws -> any PokemonListResult
    func reset() async throws
}

extension PokemonPager: PokemonPaging {}
