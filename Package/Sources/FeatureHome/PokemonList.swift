import ScreenCore
import SharedCore

struct PokemonList {
    var pokemon: [Pokemon]
    var total: Int
    var notice: FetchFailure?
}

extension PokemonList {
    init(
        _ snapshot: PokemonListSnapshot,
        notice: FetchFailure? = nil
    ) {
        self.init(
            pokemon: snapshot.pokemon,
            total: snapshot.total,
            notice: notice
        )
    }
}
