import SharedCore
import SwiftUI

struct PokemonCard: View {
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .topTrailing) {
            if !isPlaceholder {
                Text(.homeNumberPlain(pokemon.number))
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(accent.opacity(0.10))
                    .monospacedDigit()
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .accessibilityHidden(true)
            }
        }
        .background {
            LinearGradient(
                colors: [accent.opacity(0.28), accent.opacity(0.06), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .background(.quaternary.opacity(0.4))
        }
        .clipShape(.rect(cornerRadius: 20))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(.homeCardLabel(pokemon.number, pokemon.name.capitalized))
        .task(id: pokemon.artwork) {
            guard let url = pokemon.artwork else {
                return
            }

            let loaded = await ArtworkStore.shared.artwork(for: url)

            withAnimation(.easeOut(duration: 0.3)) {
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
