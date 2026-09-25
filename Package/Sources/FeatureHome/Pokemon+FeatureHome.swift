import Foundation
import SharedCore

extension [Pokemon] {
    func filtered(query: String, sort: PokemonSort) -> [Pokemon] {
        filter { query.isEmpty || $0.name.localizedStandardContains(query) }
            .sorted(by: sort.areInIncreasingOrder)
    }
}
