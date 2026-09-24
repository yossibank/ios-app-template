public struct PokemonLoadFailure: Hashable, Sendable {
    public enum Reason: Hashable, Sendable {
        case offline
        case timeout
        case server(statusCode: Int)
        case unreadable
        case closed
        case interrupted
    }

    public let reason: Reason
    public let canRetry: Bool

    public init(reason: Reason, canRetry: Bool) {
        self.reason = reason
        self.canRetry = canRetry
    }
}

public struct PokemonListSnapshot: Hashable, Sendable {
    public let pokemon: [Pokemon]
    public let hasMore: Bool
    public let total: Int

    public var incompleteCount: Int {
        pokemon.count { $0.profile == nil }
    }

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
    case degraded(PokemonListSnapshot, PokemonLoadFailure)
    case failed(PokemonLoadFailure)
    case stale
}
