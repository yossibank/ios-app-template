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
                    ? HomeStrings.progressFiltered(shown: shown, total: total, loaded: loaded)
                    : HomeStrings.progress(loaded: loaded, total: total)
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
