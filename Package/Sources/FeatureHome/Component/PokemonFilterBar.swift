import ScreenCore
import SharedCore
import SwiftUI

struct PokemonFilterBar: View {
    let types: [PokemonType]

    @Binding var selected: PokemonType?

    var body: some View {
        if !types.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Chip(
                        text: HomeStrings.filterAll,
                        tint: .secondary,
                        isOn: selected == nil
                    ) {
                        selected = nil
                    }

                    ForEach(types, id: \.self) { type in
                        Chip(
                            text: HomeStrings.typeName(type),
                            tint: type.badgeColor,
                            isOn: selected == type
                        ) {
                            selected = selected == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .scrollIndicators(.hidden)
        }
    }
}
