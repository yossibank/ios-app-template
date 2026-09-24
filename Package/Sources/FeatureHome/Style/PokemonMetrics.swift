import SwiftUI

enum PokemonMetrics {
    static let skeletonCount = 8

    static let cardCornerRadius = 20.0
    static let cardSpacing = 10.0
    static let contentInset = 12.0
    static let cardVerticalInset = 10.0
    static let contentTopInset = 8.0
    static let minimumCardWidth = 150.0

    static let gridColumns = [
        GridItem(.adaptive(minimum: minimumCardWidth), spacing: cardSpacing)
    ]

    static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardCornerRadius)
    }

    static var cardFill: some ShapeStyle {
        HierarchicalShapeStyle.quaternary.opacity(0.4)
    }
}

extension View {
    func pokemonContentInsets() -> some View {
        padding(.horizontal, PokemonMetrics.contentInset)
            .padding(.vertical, PokemonMetrics.contentTopInset)
    }

    func pokemonCardInsets() -> some View {
        padding(.horizontal, PokemonMetrics.contentInset)
            .padding(.vertical, PokemonMetrics.cardVerticalInset)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
