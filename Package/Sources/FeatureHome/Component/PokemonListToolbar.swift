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
