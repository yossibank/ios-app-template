import ScreenCore
import SharedCore
import SwiftUI

struct PokemonSkeletonGrid: View {
    var body: some View {
        ScrollView {
            PokemonGrid {
                ForEach(0..<8, id: \.self) { _ in
                    PokemonCard(pokemon: Pokemon(id: 0, name: "pokemon", artwork: nil))
                }
            }
            .skeleton()
            .pokemonContentInsets()
        }
        .scrollDisabled(true)
        .accessibilityHidden(true)
    }
}
