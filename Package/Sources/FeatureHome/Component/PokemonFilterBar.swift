import SharedCore
import SwiftUI

struct PokemonFilterBar: View {
    let types: [PokemonTypeKind]

    @Binding var selected: PokemonTypeKind?

    var body: some View {
        if !types.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterChip(
                        text: HomeStrings.filterAll,
                        color: .secondary,
                        isOn: selected == nil
                    ) {
                        selected = nil
                    }

                    ForEach(types, id: \.self) { type in
                        FilterChip(
                            text: HomeStrings.typeName(type),
                            color: type.badgeColor,
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

private struct FilterChip: View {
    let text: String
    let color: Color
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isOn ? .white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isOn ? color : Color.secondary.opacity(0.15), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
