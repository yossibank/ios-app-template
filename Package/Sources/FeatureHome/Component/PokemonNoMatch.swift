import ScreenCore
import SharedCore
import SwiftUI

struct PokemonNoMatch: View {
    let query: String
    let selectedType: PokemonTypeKind?

    var body: some View {
        if selectedType != nil {
            ContentUnavailableView {
                Label(HomeStrings.noTypeMatch, systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text(HomeStrings.noTypeMatchDescription)
            }
        } else {
            ContentUnavailableView.search(text: query)
        }
    }
}
