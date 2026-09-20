import SharedCore
import SwiftUI

extension PokemonTypeKind {
    var badgeColor: Color {
        switch self {
        case .normal: Color(red: 0.62, green: 0.63, blue: 0.62)
        case .fire: Color(red: 0.90, green: 0.16, blue: 0.16)
        case .water: Color(red: 0.16, green: 0.50, blue: 0.94)
        case .electric: Color(red: 0.81, green: 0.63, blue: 0.00)
        case .grass: Color(red: 0.25, green: 0.63, blue: 0.16)
        case .ice: Color(red: 0.24, green: 0.81, blue: 0.95)
        case .fighting: Color(red: 1.00, green: 0.50, blue: 0.00)
        case .poison: Color(red: 0.57, green: 0.25, blue: 0.80)
        case .ground: Color(red: 0.57, green: 0.32, blue: 0.13)
        case .flying: Color(red: 0.51, green: 0.73, blue: 0.94)
        case .psychic: Color(red: 0.94, green: 0.25, blue: 0.47)
        case .bug: Color(red: 0.57, green: 0.63, blue: 0.10)
        case .rock: Color(red: 0.69, green: 0.66, blue: 0.51)
        case .ghost: Color(red: 0.44, green: 0.25, blue: 0.44)
        case .dragon: Color(red: 0.31, green: 0.38, blue: 0.88)
        case .dark: Color(red: 0.38, green: 0.30, blue: 0.31)
        case .steel: Color(red: 0.38, green: 0.63, blue: 0.72)
        case .fairy: Color(red: 0.94, green: 0.44, blue: 0.94)
        case .unknown: Color(red: 0.41, green: 0.63, blue: 0.56)
        }
    }
}
