import ScreenCore
import SharedCore
import SwiftUI

struct PokemonSkeletonGrid: View {
    private static let count = 8

    var body: some View {
        ScrollView {
            PokemonGrid {
                ForEach(0..<Self.count, id: \.self) { _ in
                    PokemonCard(pokemon: .placeholder)
                }
            }
            .redacted(reason: .placeholder)
            .shimmering()
            .pokemonContentInsets()
        }
        .scrollDisabled(true)
        .accessibilityHidden(true)
    }
}

private extension Pokemon {
    static let placeholder = Pokemon(id: 0, name: "pokemon", artwork: nil)
}
