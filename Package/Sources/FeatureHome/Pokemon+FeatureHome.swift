import Foundation
import SharedCore

extension Pokemon {
    var totalBaseStat: Int {
        profile?.totalBaseStat ?? -1
    }

    func matches(_ type: PokemonType?) -> Bool {
        guard let type else {
            return true
        }

        return profile?.types.contains(type) ?? false
    }
}

extension [Pokemon] {
    var availableTypes: [PokemonType] {
        var seen: [PokemonType] = []

        for pokemon in self {
            guard let profile = pokemon.profile else {
                continue
            }

            for type in profile.types where !seen.contains(type) {
                seen.append(type)
            }
        }

        return seen
    }

    func filtered(query: String, type: PokemonType?, sort: PokemonSort) -> [Pokemon] {
        filter { pokemon in
            let matchesName = query.isEmpty || pokemon.name.localizedStandardContains(query)

            return matchesName && pokemon.matches(type)
        }
        .sorted(by: sort.areInIncreasingOrder)
    }
}
