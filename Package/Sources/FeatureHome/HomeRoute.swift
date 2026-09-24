import SharedCore

enum HomeRoute: Hashable {
    case detail(Pokemon)

    var pokemon: Pokemon {
        switch self {
        case let .detail(pokemon): pokemon
        }
    }
}
