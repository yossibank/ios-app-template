import SwiftUI
import UIKit

struct PokemonArtwork: View {
    private static let appearingScale = 0.9

    let image: UIImage?
    let initial: String?
    let accent: Color

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .transition(.opacity.combined(with: .scale(scale: Self.appearingScale)))
        } else if let initial {
            PokemonInitial(text: initial)
        } else {
            PokemonArtworkPlaceholder(accent: accent)
        }
    }
}

private struct PokemonArtworkPlaceholder: View {
    private static let fillOpacity = 0.12
    private static let inset = 14.0

    let accent: Color

    var body: some View {
        Circle()
            .fill(accent.opacity(Self.fillOpacity))
            .padding(Self.inset)
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
