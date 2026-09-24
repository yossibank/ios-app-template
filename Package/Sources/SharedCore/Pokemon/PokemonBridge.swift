import Foundation
import Shared

extension PokemonType {
    init(_ kind: PokemonTypeKind) {
        self = switch kind {
        case .normal: .normal
        case .fire: .fire
        case .water: .water
        case .electric: .electric
        case .grass: .grass
        case .ice: .ice
        case .fighting: .fighting
        case .poison: .poison
        case .ground: .ground
        case .flying: .flying
        case .psychic: .psychic
        case .bug: .bug
        case .rock: .rock
        case .ghost: .ghost
        case .dragon: .dragon
        case .dark: .dark
        case .steel: .steel
        case .fairy: .fairy
        case .unknown: .unknown
        }
    }
}

extension PokemonStat {
    init(_ kind: PokemonStatKind) {
        self = switch kind {
        case .hp: .hp
        case .attack: .attack
        case .defense: .defense
        case .specialAttack: .specialAttack
        case .specialDefense: .specialDefense
        case .speed: .speed
        case .other: .other
        }
    }
}

extension PokemonBaseStat {
    init(_ stat: Shared.PokemonBaseStat) {
        self.init(
            kind: PokemonStat(stat.kind),
            value: Int(stat.value)
        )
    }
}

extension PokemonProfile {
    init(_ detail: PokemonEntryDetailLoaded) {
        self.init(
            artwork: detail.imageUrl.flatMap(URL.init(string:)),
            types: detail.types.map(PokemonType.init),
            baseStats: detail.baseStats.map(PokemonBaseStat.init)
        )
    }
}

extension Pokemon {
    init(_ entry: PokemonEntry) {
        let profile: PokemonProfile? = switch onEnum(of: entry.detail) {
        case let .loaded(detail): PokemonProfile(detail)
        case .missing: nil
        }

        self.init(
            id: Int(entry.id),
            name: entry.name,
            profile: profile
        )
    }
}

extension PokemonLoadFailure {
    static let interrupted = PokemonLoadFailure(reason: .interrupted, canRetry: true)

    init(_ failure: any ApiFailure) {
        let reason: Reason = switch onEnum(of: failure) {
        case .offline: .offline
        case .timeout: .timeout
        case let .server(server): .server(statusCode: Int(server.statusCode))
        case .unreadable: .unreadable
        case .closed: .closed
        }

        self.init(reason: reason, canRetry: failure.canRetry)
    }
}

extension PokemonListSnapshot {
    init(pokemon: [PokemonEntry], hasMore: Bool, total: Int32) {
        self.init(
            pokemon: pokemon.map(Pokemon.init),
            hasMore: hasMore,
            total: Int(total)
        )
    }
}

extension PokemonListPage {
    init(_ result: PokemonListResult) {
        switch onEnum(of: result) {
        case let .loaded(loaded):
            let snapshot = PokemonListSnapshot(
                pokemon: loaded.pokemon,
                hasMore: loaded.hasMore,
                total: loaded.total
            )

            self = if let failure = loaded.failure {
                .degraded(snapshot, PokemonLoadFailure(failure))
            } else {
                .loaded(snapshot)
            }

        case let .failed(failed):
            self = .failed(PokemonLoadFailure(failed.failure))

        case .stale:
            self = .stale
        }
    }
}
