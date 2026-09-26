import SwiftUI

struct PokemonListToolbar: View {
    let shown: Int
    let loaded: Int
    let total: Int
    let filtering: Bool

    private var showsProgress: Bool {
        !filtering && total > 0 && loaded < total
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(
                filtering
                    ? .homeProgressFiltered(shown.ungrouped, total.ungrouped, loaded.ungrouped)
                    : .homeProgress(loaded.ungrouped, total.ungrouped)
            )
            .font(.caption.weight(.medium))
            .monospacedDigit()
            .contentTransition(.numericText())

            if showsProgress {
                ProgressView(value: Double(loaded), total: Double(total))
                    .frame(width: 64)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .animation(.snappy, value: loaded)
        .animation(.snappy, value: showsProgress)
    }
}

#Preview("読み込み途中") {
    PokemonListToolbar(shown: 40, loaded: 40, total: 1351, filtering: false)
        .padding()
}

#Preview("絞り込み中") {
    PokemonListToolbar(shown: 3, loaded: 40, total: 1351, filtering: true)
        .padding()
}
