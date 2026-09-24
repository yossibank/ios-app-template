import SharedCore
import SwiftUI

struct PokemonArtwork: View {
    let detail: PokemonEntryDetailLoaded?
    let fallback: String
    let accent: Color

    private var large: URL? {
        (detail?.artworkUrl ?? detail?.spriteUrl).flatMap(URL.init(string:))
    }

    var body: some View {
        if let large {
            AsyncImage(
                url: large,
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

struct PokemonArtworkPlaceholder: View {
    let accent: Color

    var body: some View {
        Circle()
            .fill(accent.opacity(0.12))
            .padding(14)
    }
}

struct PokemonInitial: View {
    let text: String

    var body: some View {
        Text(text.prefix(1).uppercased())
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.secondary)
    }
}
