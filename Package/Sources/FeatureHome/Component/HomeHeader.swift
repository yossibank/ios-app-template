import ScreenCore
import SwiftUI

struct HomeHeader: View {
    let total: Int?
    let onLogout: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(.homeCollection)
                    .font(.atelierSerif(17, relativeTo: .subheadline, italic: true))
                    .foregroundStyle(Color.atelierMuted)

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(.homeTitle)
                        .font(.atelierMincho(30, relativeTo: .largeTitle, bold: true))
                        .tracking(1.8)
                        .accessibilityAddTraits(.isHeader)

                    if let total {
                        Text(total, format: .number)
                            .font(.atelierSerif(16, relativeTo: .callout, semibold: true))
                            .foregroundStyle(Color.atelierMuted)
                    }
                }
            }

            Spacer()

            Menu {
                Button(role: .destructive, action: onLogout) {
                    Text(.homeLogout)
                }
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 17, weight: .light))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Circle()
                            .stroke(Color.atelierLine, lineWidth: 1)
                    }
                    .contentShape(.circle)
            }
            .accessibilityLabel(Text(.homeAccount))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}

#Preview("見出し") {
    HomeHeader(total: 194) {}
        .background(Color.atelierGround)
}
