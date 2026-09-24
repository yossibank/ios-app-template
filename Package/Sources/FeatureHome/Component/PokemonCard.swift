import SharedCore
import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon

    private var profile: PokemonProfile? {
        pokemon.profile
    }

    private var accent: Color {
        pokemon.accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(HomeStrings.number(pokemon.id))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(artwork: profile?.artwork, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(2)

            if let profile, !profile.types.isEmpty {
                PokemonTypeBadges(types: profile.types, spacing: 4)
                    .padding(.top, 6)
            }

            if let profile, !profile.baseStats.isEmpty {
                PokemonStatBar(total: profile.totalBaseStat, accent: accent)
                    .padding(.top, 10)
            }
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

    private var accessibilityLabel: String {
        var parts = [HomeStrings.number(pokemon.id), pokemon.name.capitalized]

        if let profile {
            parts += profile.types.map(HomeStrings.typeName)

            if !profile.baseStats.isEmpty {
                parts.append(HomeStrings.totalCaption)
                parts.append(HomeStrings.total(profile.totalBaseStat))
            }
        }

        return parts.joined(separator: "、")
    }
}
