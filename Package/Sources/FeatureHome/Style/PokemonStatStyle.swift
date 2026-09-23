import SharedCore
import SwiftUI

extension PokemonStatKind {
    var barColor: Color {
        switch self {
        case .hp: Color(red: 0.42, green: 0.75, blue: 0.35)
        case .attack: Color(red: 0.91, green: 0.45, blue: 0.29)
        case .defense: Color(red: 0.29, green: 0.56, blue: 0.85)
        case .specialAttack: Color(red: 0.61, green: 0.42, blue: 0.84)
        case .specialDefense: Color(red: 0.25, green: 0.71, blue: 0.66)
        case .speed: Color(red: 0.88, green: 0.69, blue: 0.23)
        case .other: Color(red: 0.62, green: 0.62, blue: 0.62)
        }
    }
}
