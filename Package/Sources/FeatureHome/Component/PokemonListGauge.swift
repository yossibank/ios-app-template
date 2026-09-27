import ScreenCore
import SwiftUI

struct PokemonListGauge: View {
    let loaded: Int
    let total: Int
    let matched: Int?

    var body: some View {
        GaugeView(fraction: fraction) {
            HStack(spacing: 4) {
                if let matched {
                    Text(.homeProgressFilteredCount(matched))

                    Text(.homeProgressFilteredDetail(total, loaded))
                        .foregroundStyle(.secondary)
                } else {
                    Text(loaded, format: .number)

                    Text(.homeProgressTotal(total))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private extension PokemonListGauge {
    var fraction: Double? {
        if matched == nil, loaded < total {
            Double(loaded) / Double(total)
        } else {
            nil
        }
    }
}

#Preview("読み込み途中") {
    PokemonListGauge(loaded: 40, total: 1351, matched: nil)
}

#Preview("読み込み完了") {
    PokemonListGauge(loaded: 1351, total: 1351, matched: nil)
}

#Preview("絞り込み中") {
    PokemonListGauge(loaded: 40, total: 1351, matched: 3)
}
