import SwiftUI

struct PokemonGrid<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160), spacing: 8)],
            spacing: 8
        ) {
            content()
        }
    }
}
