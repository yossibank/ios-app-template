import SharedCore
import SwiftUI

struct PokemonArtwork: View {
    let artwork: URL?
    let fallback: String
    let accent: Color

    var body: some View {
        if let artwork {
            AsyncImage(
                url: artwork,
                transaction: Transaction(animation: .easeOut(duration: 0.2))
            ) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .transition(.opacity)
                } else {
                    PokemonArtworkPlaceholder(accent: accent)
                }
            }
        } else {
            PokemonInitial(text: fallback)
        }
    }
}

private struct PokemonArtworkPlaceholder: View {
    let accent: Color

    var body: some View {
        Circle()
            .fill(accent.opacity(0.12))
            .padding(14)
    }
}

private struct PokemonInitial: View {
    let text: String

    var body: some View {
        Text(text.prefix(1).uppercased())
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.secondary)
    }
}
