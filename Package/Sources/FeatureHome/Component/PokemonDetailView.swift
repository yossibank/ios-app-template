import ScreenCore
import SharedCore
import SwiftUI

struct PokemonDetailView: View {
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
            Text(HomeStrings.number(Int(pokemon.id)))
                .font(.headline)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            PokemonArtwork(detail: detail, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 280)

            if let detail, !detail.types.isEmpty {
                HStack(spacing: 8) {
                    ForEach(detail.types, id: \.self) { type in
                        PokemonTypeBadge(type: type)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private var stats: some View {
        if let detail, !detail.baseStats.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(HomeStrings.totalCaption)
                        .font(.headline)

                    Spacer()

                    Text(HomeStrings.total(Int(detail.totalBaseStat)))
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                }

                ForEach(Array(detail.baseStats.enumerated()), id: \.offset) { _, stat in
                    PokemonStatRow(stat: stat)
                }
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            .padding(20)
        } else {
            Text(HomeStrings.detailMissing)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(32)
        }
    }
}

struct PokemonStatRow: View {
    let stat: PokemonBaseStat

    private var fraction: Double {
        min(max(Double(stat.value) / maxBaseStat, 0.02), 1)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(HomeStrings.statName(stat.kind))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            Text("\(Int(stat.value))")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)

                    Capsule()
                        .fill(stat.kind.barColor)
                        .frame(width: geometry.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 3)
    }
}
