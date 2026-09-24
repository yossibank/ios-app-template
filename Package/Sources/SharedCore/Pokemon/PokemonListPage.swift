import ScreenCore

public struct PokemonListSnapshot: Hashable, Sendable {
    public let pokemon: [Pokemon]
    public let hasMore: Bool
    public let total: Int

    public init(
        pokemon: [Pokemon],
        hasMore: Bool,
        total: Int
    ) {
        self.pokemon = pokemon
        self.hasMore = hasMore
        self.total = total
    }
}

public enum PokemonListPage: Hashable, Sendable {
    case loaded(PokemonListSnapshot)
    case degraded(PokemonListSnapshot, FetchFailure)
    case failed(FetchFailure)
    case stale
}
