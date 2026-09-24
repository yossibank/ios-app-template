import ScreenCore
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

private struct PokemonStatTotal: View {
    let total: Int

    var body: some View {
        Text(HomeStrings.total(total))
            .font(.subheadline.weight(.bold))
            .monospacedDigit()
            .lineLimit(1)
    }
}

private struct StatFillBar: View {
    let total: Int
    let accent: Color

    private var fraction: Double {
        min(max(Double(total) / PokemonMetrics.maxTotalBaseStat, 0.04), 1)
    }

    var body: some View {
        CapsuleMeter(fraction: fraction, tint: accent)
            .frame(height: 7)
            .frame(minWidth: 48)
    }
}
