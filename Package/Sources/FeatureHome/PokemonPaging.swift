import SharedCore

protocol PokemonPaging: Sendable {
    func loadNext() async throws -> PokemonListResult
    func reset() async throws
}

extension PokemonPager: @retroactive @unchecked Sendable, PokemonPaging {}
