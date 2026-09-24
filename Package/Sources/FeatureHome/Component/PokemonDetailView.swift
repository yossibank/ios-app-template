import ScreenCore
import SharedCore
import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon

    private var profile: PokemonProfile? {
        pokemon.profile
    }

    private var accent: Color {
        pokemon.accentColor
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                stats
            }
        }
        .background(alignment: .top) {
            LinearGradient(
                colors: [accent.opacity(0.45), accent.opacity(0.14), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 440)
            .ignoresSafeArea(edges: .top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Text(HomeStrings.number(pokemon.id))
                .font(.headline)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(artwork: profile?.artwork, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 280)
                .accessibilityHidden(true)

            if let profile, !profile.types.isEmpty {
                PokemonTypeBadges(types: profile.types, spacing: 8)
                    .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private var stats: some View {
        if let profile, !profile.baseStats.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(HomeStrings.totalCaption)
                        .font(.headline)

                    Spacer()

                    Text(HomeStrings.total(profile.totalBaseStat))
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                }

                ForEach(Array(profile.baseStats.enumerated()), id: \.offset) { _, stat in
                    PokemonStatRow(stat: stat)
                }
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: PokemonMetrics.cardShape)
            .padding(20)
        } else {
            Text(HomeStrings.detailMissing)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(32)
        }
    }
}

private struct PokemonStatRow: View {
    @ScaledMetric(relativeTo: .caption) private var nameWidth = 60
    @ScaledMetric(relativeTo: .subheadline) private var valueWidth = 36

    let stat: PokemonBaseStat

    private var fraction: Double {
        min(max(Double(stat.value) / PokemonMetrics.maxBaseStat, 0.02), 1)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(HomeStrings.statName(stat.kind))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: nameWidth, alignment: .leading)

            Text("\(stat.value)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(width: valueWidth, alignment: .trailing)

            CapsuleMeter(fraction: fraction, tint: stat.kind.barColor)
                .frame(height: 8)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }
}
