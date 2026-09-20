import Foundation
import SharedCore

enum HomeStrings {
    static var title: String {
        String(localized: "home.title", bundle: .module)
    }

    static var searchPrompt: String {
        String(localized: "home.search_prompt", bundle: .module)
    }

    static var emptyTitle: String {
        String(localized: "home.empty_title", bundle: .module)
    }

    static var emptyDescription: String {
        String(localized: "home.empty_description", bundle: .module)
    }

    static var reload: String {
        String(localized: "home.reload", bundle: .module)
    }

    static var offline: String {
        String(localized: "home.offline", bundle: .module)
    }

    static var unreadable: String {
        String(localized: "home.unreadable", bundle: .module)
    }

    static var unexpected: String {
        String(localized: "home.unexpected", bundle: .module)
    }

    static func serverError(statusCode: Int) -> String {
        String(
            format: String(localized: "home.server_error", bundle: .module),
            statusCode
        )
    }

    static func number(_ id: Int) -> String {
        String(
            format: String(localized: "home.number", bundle: .module),
            id
        )
    }

    static func total(_ value: Int) -> String {
        String(
            format: String(localized: "home.total", bundle: .module),
            value
        )
    }

    static func typeName(_ kind: PokemonTypeKind) -> String {
        switch kind {
        case .normal: String(localized: "home.type.normal", bundle: .module)
        case .fire: String(localized: "home.type.fire", bundle: .module)
        case .water: String(localized: "home.type.water", bundle: .module)
        case .electric: String(localized: "home.type.electric", bundle: .module)
        case .grass: String(localized: "home.type.grass", bundle: .module)
        case .ice: String(localized: "home.type.ice", bundle: .module)
        case .fighting: String(localized: "home.type.fighting", bundle: .module)
        case .poison: String(localized: "home.type.poison", bundle: .module)
        case .ground: String(localized: "home.type.ground", bundle: .module)
        case .flying: String(localized: "home.type.flying", bundle: .module)
        case .psychic: String(localized: "home.type.psychic", bundle: .module)
        case .bug: String(localized: "home.type.bug", bundle: .module)
        case .rock: String(localized: "home.type.rock", bundle: .module)
        case .ghost: String(localized: "home.type.ghost", bundle: .module)
        case .dragon: String(localized: "home.type.dragon", bundle: .module)
        case .dark: String(localized: "home.type.dark", bundle: .module)
        case .steel: String(localized: "home.type.steel", bundle: .module)
        case .fairy: String(localized: "home.type.fairy", bundle: .module)
        case .unknown: String(localized: "home.type.unknown", bundle: .module)
        }
    }
}
