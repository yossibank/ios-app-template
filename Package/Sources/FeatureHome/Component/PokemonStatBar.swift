import SwiftUI

struct PokemonStatBar: View {
    let total: Int
    let accent: Color

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                StatFillBar(total: total, accent: accent)
                PokemonStatTotal(total: total)
            }

            VStack(alignment: .leading, spacing: 4) {
                PokemonStatTotal(total: total)
                StatFillBar(total: total, accent: accent)
            }
        }
    }
}

struct PokemonStatTotal: View {
    let total: Int

    var body: some View {
        Text(HomeStrings.total(total))
            .font(.subheadline.weight(.bold))
            .monospacedDigit()
            .lineLimit(1)
    }
}

struct StatFillBar: View {
    let total: Int
    let accent: Color

    private var fraction: Double {
        min(max(Double(total) / maxTotalBaseStat, 0.04), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)

                Capsule()
                    .fill(accent)
                    .frame(width: geometry.size.width * fraction)
            }
        }
        .frame(height: 7)
        .frame(minWidth: 48)
    }
}
