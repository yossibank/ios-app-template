import SharedCore
import SwiftUI

struct PokemonListToolbar: View {
    let shown: Int
    let loaded: Int
    let total: Int
    let filtering: Bool

    @Binding var sort: PokemonSort

    var body: some View {
        HStack {
            Text(
                filtering
                    ? HomeStrings.progressFiltered(shown: shown, total: total, loaded: loaded)
                    : HomeStrings.progress(loaded: loaded, total: total)
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()

            Spacer()

            Menu {
                Picker(HomeStrings.sortTitle, selection: $sort) {
                    ForEach(PokemonSort.allCases, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                }
            } label: {
                Text(sort.label)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 4)
    }
}

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

struct FilterChip: View {
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
