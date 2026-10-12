import SwiftUI

struct ScreenFailureView: View {
    let failure: FetchFailure
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Rectangle()
                .fill(Color.atelierInk)
                .frame(width: 40, height: 1)

            Text(.screenLoadFailed)
                .font(.atelierMincho(20, relativeTo: .title3, bold: true))

            Text(failure.message)
                .font(.footnote)
                .foregroundStyle(Color.atelierMuted)
                .multilineTextAlignment(.center)

            if failure.canRetry {
                Button(action: retry) {
                    Text(.screenRetry)
                }
                .buttonStyle(AtelierOutlineButtonStyle())
                .padding(.top, 8)
            }
        }
        .foregroundStyle(Color.atelierInk)
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.atelierGround)
    }
}

#Preview("失敗") {
    ScreenFailureView(failure: FetchFailure("接続を確認してください")) {}
}

#Preview("失敗（再試行できない）") {
    ScreenFailureView(
        failure: FetchFailure(
            "データを読み取れませんでした",
            canRetry: false
        )
    ) {}
}
