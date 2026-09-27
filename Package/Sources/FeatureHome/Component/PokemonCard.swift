import SharedCore
import SwiftUI

struct PokemonCard: View {
    @Environment(\.redactionReasons) private var redactionReasons

    @State private var phase: Phase

    let pokemon: Pokemon

    init(pokemon: Pokemon) {
        self.pokemon = pokemon

        _phase = State(
            initialValue: pokemon.artwork == nil ? .unavailable : .loading
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(.homeNumber(pokemon.number))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            artwork

            Spacer(minLength: 0)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(2)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .background(alignment: .topTrailing) {
            numberBackground
        }
        .background {
            cardBackground
        }
        .clipShape(
            .rect(cornerRadius: 16)
        )
        .task(id: pokemon.artwork) {
            await load()
        }
    }
}

private extension PokemonCard {
    var artwork: some View {
        Group {
            switch phase {
            case let .loaded(artwork):
                Image(uiImage: artwork.image)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))

            case .unavailable where !isPlaceholder:
                Text(pokemon.name.prefix(1).uppercased())
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            default:
                Circle()
                    .fill(color.opacity(0.12))
                    .padding(16)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var numberBackground: some View {
        if !isPlaceholder {
            Text(pokemon.number)
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(color.opacity(0.10))
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, 8)
        }
    }

    var cardBackground: some View {
        LinearGradient(
            colors: [color.opacity(0.28), color.opacity(0.06), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.quaternary.opacity(0.4))
    }
}

private extension PokemonCard {
    var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    var color: Color {
        if isPlaceholder {
            .secondary
        } else if case let .loaded(artwork) = phase {
            artwork.tint
        } else {
            .gray.opacity(0.5)
        }
    }

    func load() async {
        guard let url = pokemon.artwork else {
            return
        }

        let loaded = await ArtworkStore.shared.artwork(for: url)

        guard !Task.isCancelled else {
            return
        }

        withAnimation(.easeOut(duration: 0.3)) {
            phase = loaded.map(Phase.loaded) ?? .unavailable
        }
    }
}

private extension PokemonCard {
    enum Phase {
        case loading
        case loaded(Artwork)
        case unavailable
    }
}

#Preview("カード") {
    PokemonCard(pokemon: Pokemon(id: 25, name: "pikachu", artwork: nil))
        .frame(width: 160)
        .fixedSize(horizontal: false, vertical: true)
}

#Preview("カード（読み込み中）") {
    PokemonCard(pokemon: Pokemon(id: 0, name: "pikachu", artwork: nil))
        .redacted(reason: .placeholder)
        .frame(width: 160)
        .fixedSize(horizontal: false, vertical: true)
}
