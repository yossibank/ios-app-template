import Foundation

public enum PokemonType: CaseIterable, Hashable, Sendable {
    case normal
    case fire
    case water
    case electric
    case grass
    case ice
    case fighting
    case poison
    case ground
    case flying
    case psychic
    case bug
    case rock
    case ghost
    case dragon
    case dark
    case steel
    case fairy
    case unknown
}

public enum PokemonStat: CaseIterable, Hashable, Sendable {
    case hp
    case attack
    case defense
    case specialAttack
    case specialDefense
    case speed
    case other
}

public struct PokemonBaseStat: Hashable, Sendable {
    public let kind: PokemonStat
    public let value: Int

    public init(kind: PokemonStat, value: Int) {
        self.kind = kind
        self.value = value
    }
}

public struct PokemonProfile: Hashable, Sendable {
    public let artwork: URL?
    public let types: [PokemonType]
    public let baseStats: [PokemonBaseStat]
    public let totalBaseStat: Int

    public init(
        artwork: URL?,
        types: [PokemonType],
        baseStats: [PokemonBaseStat]
    ) {
        self.artwork = artwork
        self.types = types
        self.baseStats = baseStats
        self.totalBaseStat = baseStats.reduce(0) { $0 + $1.value }
    }
}

public struct Pokemon: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let profile: PokemonProfile?

    public init(
        id: Int,
        name: String,
        profile: PokemonProfile?
    ) {
        self.id = id
        self.name = name
        self.profile = profile
    }
}
