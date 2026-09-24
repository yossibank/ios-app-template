import SharedCore
import SwiftUI

struct PokemonTypeBadge: View {
    let type: PokemonType

    var body: some View {
        Text(HomeStrings.typeName(type))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(type.onBadgeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(type.badgeColor, in: Capsule())
    }
}

struct PokemonTypeBadges: View {
    let types: [PokemonType]
    let spacing: Double

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(types, id: \.self) { type in
                PokemonTypeBadge(type: type)
            }
        }
    }
}
