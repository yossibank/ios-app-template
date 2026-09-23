import SharedCore

protocol PokemonPaging: Sendable {
    func loadNext() async throws -> PokemonListResult
    func retryMissingDetails() async throws -> PokemonListResult
    func reset() async throws
    func close()
}

extension PokemonPager: @retroactive @unchecked Sendable, PokemonPaging {}
