import SharedCore
import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon

    private let accent = Color.accentColor

    private var accessibilityLabel: String {
        [HomeStrings.number(pokemon.id), pokemon.name.capitalized].joined(separator: "、")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(HomeStrings.number(pokemon.id))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(artwork: pokemon.artwork, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(2)
        }
        .pokemonCardInsets()
        .background(alignment: .topTrailing) {
            Text(HomeStrings.numberPlain(pokemon.id))
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(accent.opacity(0.10))
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, 6)
                .accessibilityHidden(true)
        }
        .background {
            PokemonMetrics.cardShape
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.28), accent.opacity(0.06), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(PokemonMetrics.cardFill, in: PokemonMetrics.cardShape)
        }
        .contentShape(PokemonMetrics.cardShape)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
}
