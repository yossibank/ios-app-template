import SwiftUI

struct PokemonListToolbar: View {
    let shown: Int
    let loaded: Int
    let total: Int
    let filtering: Bool

    var body: some View {
        HStack {
            Text(
                filtering
                    ? .homeProgressFiltered(shown.ungrouped, total.ungrouped, loaded.ungrouped)
                    : .homeProgress(loaded.ungrouped, total.ungrouped)
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
