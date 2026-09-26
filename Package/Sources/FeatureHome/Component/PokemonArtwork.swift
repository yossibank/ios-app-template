import SwiftUI
import UIKit

struct PokemonArtwork: View {
    let image: UIImage?
    let initial: String?
    let accent: Color

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else if let initial {
            PokemonInitial(text: initial)
        } else {
            PokemonArtworkPlaceholder(accent: accent)
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
