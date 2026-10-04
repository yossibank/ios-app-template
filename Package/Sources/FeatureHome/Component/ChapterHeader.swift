import ScreenCore
import SwiftUI

struct ChapterHeader: View {
    let numeral: String
    let first: Int
    let last: Int
    var isLoading = false

    var body: some View {
        HStack(spacing: 12) {
            Text(numeral)
                .tracking(2.6)

            Rectangle()
                .fill(Color.atelierLine)
                .frame(height: 1)

            HStack(spacing: 6) {
                Text(.homeChapterRange(first, last))

                if isLoading {
                    Text(.homeChapterLoading)
                        .font(.atelierMincho(11, relativeTo: .caption2))
                }
            }
            .tracking(1.3)
        }
        .font(.atelierSerif(13, relativeTo: .footnote, semibold: true))
        .foregroundStyle(Color.atelierMuted)
        .padding(.top, 10)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("章の見出し") {
    VStack(spacing: 24) {
        ChapterHeader(numeral: "I", first: 1, last: 20)
        ChapterHeader(numeral: "II", first: 21, last: 40, isLoading: true)
    }
    .padding(20)
    .background(Color.atelierGround)
}
