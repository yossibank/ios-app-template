import SharedCore
import SwiftUI

struct PokemonCard: View {
    private static let watermarkSize = 64.0
    private static let watermarkOpacity = 0.10
    private static let watermarkInset = 6.0
    private static let gradientOpacities = [0.28, 0.06, 0]
    private static let artworkFadeDuration = 0.3

    @Environment(\.redactionReasons) private var redactionReasons
    @State private var artwork: Artwork?

    let pokemon: Pokemon

    private var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    private var accent: Color {
        isPlaceholder ? .secondary : artwork?.tint ?? .accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(.homeNumber(pokemon.number))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(
                image: artwork?.image,
                initial: pokemon.artwork == nil && !isPlaceholder ? pokemon.name : nil,
                accent: accent
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(2)
        }
        .pokemonCardInsets()
        .background(alignment: .topTrailing) {
            if !isPlaceholder {
                Text(.homeNumberPlain(pokemon.number))
                    .font(.system(size: Self.watermarkSize, weight: .black, design: .rounded))
                    .foregroundStyle(accent.opacity(Self.watermarkOpacity))
                    .monospacedDigit()
                    .lineLimit(1)
                    .padding(.horizontal, Self.watermarkInset)
                    .accessibilityHidden(true)
            }
        }
        .background {
            PokemonMetrics.cardShape
                .fill(
                    LinearGradient(
                        colors: Self.gradientOpacities.map { accent.opacity($0) },
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(PokemonMetrics.cardFill, in: PokemonMetrics.cardShape)
        }
        .contentShape(PokemonMetrics.cardShape)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(.homeCardLabel(pokemon.number, pokemon.name.capitalized))
        .task(id: pokemon.artwork) {
            guard let url = pokemon.artwork else {
                return
            }

            let loaded = await ArtworkStore.shared.artwork(for: url)

            withAnimation(.easeOut(duration: Self.artworkFadeDuration)) {
                artwork = loaded
            }
        }
    }
}

#Preview("カード") {
    PokemonCard(pokemon: Pokemon(id: 25, name: "pikachu", artwork: nil))
        .frame(width: 170)
        .padding()
}

#Preview("カード（読み込み中）") {
    PokemonCard(pokemon: Pokemon(id: 0, name: "pokemon", artwork: nil))
        .redacted(reason: .placeholder)
        .frame(width: 170)
        .padding()
}
