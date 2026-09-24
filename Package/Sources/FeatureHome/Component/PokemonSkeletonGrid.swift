import SwiftUI

struct PokemonSkeletonGrid: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: PokemonMetrics.gridColumns, spacing: 10) {
                ForEach(0..<PokemonMetrics.skeletonCount, id: \.self) { _ in
                    PokemonSkeletonCard()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollDisabled(true)
    }
}

private struct PokemonSkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokemonSkeletonBlock(width: 44, height: 12)

            Circle()
                .fill(.quaternary)
                .padding(12)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            PokemonSkeletonBlock(width: 96, height: 16)
                .padding(.top, 2)

            PokemonSkeletonBlock(width: 64, height: 12)
                .padding(.top, 8)

            PokemonSkeletonBlock(width: nil, height: 7)
                .padding(.top, 10)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct PokemonSkeletonBlock: View {
    let width: CGFloat?
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(.quaternary)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}
