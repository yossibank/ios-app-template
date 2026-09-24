import SwiftUI

struct PokemonGrid<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(columns: PokemonMetrics.gridColumns, spacing: PokemonMetrics.cardSpacing) {
            content()
        }
    }
}
