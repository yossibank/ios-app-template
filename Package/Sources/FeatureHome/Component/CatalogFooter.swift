import ScreenCore
import SwiftUI

struct CatalogFooter: View {
    let loaded: Int
    let total: Int

    var body: some View {
        HStack(spacing: 12) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.atelierTrack)

                    Rectangle()
                        .fill(Color.atelierInk)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 2)
            .animation(.snappy, value: fraction)

            HStack(spacing: 4) {
                Text(loaded, format: .number)

                Text(.homeProgressTotal(total))
                    .foregroundStyle(Color.atelierMuted)
            }
            .font(.atelierSerif(15, relativeTo: .footnote, semibold: true))
            .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.atelierGround)
        .accessibilityElement(children: .combine)
    }
}

private extension CatalogFooter {
    var fraction: CGFloat {
        total > 0 ? CGFloat(loaded) / CGFloat(total) : 0
    }
}

#Preview("読み込み途中") {
    CatalogFooter(loaded: 20, total: 194)
}

#Preview("読み込み完了") {
    CatalogFooter(loaded: 194, total: 194)
}
