public protocol PokemonFetching: Sendable {
    func fetchPage(limit: Int32, offset: Int32) async throws -> any PokemonListResult
}

extension PokemonApi: PokemonFetching {}
