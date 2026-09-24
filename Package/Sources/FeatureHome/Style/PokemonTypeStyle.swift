import SharedCore
import SwiftUI
import UIKit

extension PokemonTypeKind {
    var badgeColor: Color {
        switch self {
        case .normal: Color(red: 0.62, green: 0.63, blue: 0.62)
        case .fire: Color(red: 0.86, green: 0.14, blue: 0.15)
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

extension PokemonTypeKind {
    var onBadgeColor: Color {
        badgeColor.wcagLuminance > 0.18 ? Color(white: 0.1) : .white
    }
}

extension PokemonEntry {
    var accentColor: Color {
        loadedDetail?.types.first?.badgeColor ?? .secondary
    }
}

private extension Color {
    var wcagLuminance: Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        func channel(_ value: CGFloat) -> Double {
            let v = Double(value)
            return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }
}
