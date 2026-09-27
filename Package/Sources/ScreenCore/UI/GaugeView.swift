import SwiftUI

public struct GaugeView<Label: View>: View {
    private let fraction: Double?
    private let label: Label

    public init(
        fraction: Double?,
        @ViewBuilder label: () -> Label
    ) {
        self.fraction = fraction
        self.label = label()
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let fraction {
                ring(fraction)
                    .transition(.opacity)
            }

            label
                .font(.caption.weight(.medium))
                .monospacedDigit()
                .contentTransition(.symbolEffect)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .animation(.snappy, value: fraction)
    }
}

private extension GaugeView {
    func ring(_ fraction: Double) -> some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 2)

            Circle()
                .trim(
                    from: 0,
                    to: fraction
                )
                .stroke(
                    .primary,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 12, height: 12)
    }
}

#Preview("進捗あり") {
    GaugeView(fraction: 40 / 1351) {
        Text("40 / 1,351")
    }
}

#Preview("進捗なし") {
    GaugeView(fraction: nil) {
        Text("3 件")
    }
}
