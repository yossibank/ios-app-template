import ScreenCore
import SharedCore
import SwiftUI

struct PokemonCard: View {
    let pokemon: PokemonEntry

    private var detail: PokemonEntryDetailLoaded? {
        guard case let .loaded(detail) = onEnum(of: pokemon.detail) else {
            return nil
        }
        return detail
    }

    private var accent: Color {
        detail?.types.first?.badgeColor ?? .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(HomeStrings.number(Int(pokemon.id)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(detail: detail, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(2)

            if let detail, !detail.types.isEmpty {
                HStack(spacing: 4) {
                    ForEach(detail.types, id: \.self) { type in
                        PokemonTypeBadge(type: type)
                    }
                }
                .padding(.top, 6)
            }

            if let detail, !detail.baseStats.isEmpty {
                PokemonStatBar(total: Int(detail.totalBaseStat), accent: accent)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .topTrailing) {
            Text(HomeStrings.numberPlain(Int(pokemon.id)))
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(accent.opacity(0.10))
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, 6)
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.28), accent.opacity(0.06), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
