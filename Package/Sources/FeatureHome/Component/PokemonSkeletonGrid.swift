import ScreenCore
import SwiftUI

struct PokemonSkeletonGrid: View {
    var body: some View {
        ScrollView {
            PokemonGrid {
                ForEach(0..<PokemonMetrics.skeletonCount, id: \.self) { _ in
                    PokemonSkeletonCard()
                }
            }
            .pokemonContentInsets()
        }
        .scrollDisabled(true)
        .accessibilityHidden(true)
    }
}

private struct PokemonSkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(width: 44, height: 12)

            Circle()
                .fill(.quaternary)
                .padding(12)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            SkeletonBlock(width: 96, height: 16)
                .padding(.top, 2)

            SkeletonBlock(width: 64, height: 12)
                .padding(.top, 8)

            SkeletonBlock(height: 7)
                .padding(.top, 10)
        }
        .padding(.horizontal, PokemonMetrics.contentInset)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: PokemonMetrics.cardShape)
    }
}
