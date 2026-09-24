#if DEBUG
    import Foundation

    public extension [PokemonBaseStat] {
        static func spread(_ values: [Int]) -> [PokemonBaseStat] {
            let order: [PokemonStat] = [.hp, .attack, .defense, .specialAttack, .specialDefense, .speed]

            return zip(order, values).map { PokemonBaseStat(kind: $0, value: $1) }
        }
    }

    public extension Pokemon {
        static func fixture(
            id: Int,
            name: String,
            types: [PokemonType] = [.grass],
            baseStats: [PokemonBaseStat] = [PokemonBaseStat(kind: .hp, value: 45)],
            artwork: URL? = nil
        ) -> Pokemon {
            Pokemon(
                id: id,
                name: name,
                profile: PokemonProfile(
                    artwork: artwork,
                    types: types,
                    baseStats: baseStats
                )
            )
        }

        static func incomplete(id: Int, name: String) -> Pokemon {
            Pokemon(id: id, name: name, profile: nil)
        }
    }
#endif
