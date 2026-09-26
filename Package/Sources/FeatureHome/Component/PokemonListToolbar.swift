import SwiftUI

struct PokemonListToolbar: View {
    private static let progressWidth = 64.0
    private static let spacing = 10.0
    private static let horizontalInset = 14.0
    private static let verticalInset = 8.0

    let shown: Int
    let loaded: Int
    let total: Int
    let filtering: Bool

    private var showsProgress: Bool {
        !filtering && total > 0 && loaded < total
    }

    var body: some View {
        HStack(spacing: Self.spacing) {
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
                    .frame(width: Self.progressWidth)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, Self.horizontalInset)
        .padding(.vertical, Self.verticalInset)
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
