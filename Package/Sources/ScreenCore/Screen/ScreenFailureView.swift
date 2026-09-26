import SwiftUI

struct ScreenFailureView: View {
    let failure: FetchFailure
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(.screenLoadFailed, systemImage: "exclamationmark.triangle")
        } description: {
            Text(failure.message)
        } actions: {
            if failure.canRetry {
                Button(.screenRetry, action: retry)
            }
        }
    }
}

#Preview("失敗") {
    ScreenFailureView(failure: FetchFailure("ネットワークに接続できません")) {}
}

#Preview("失敗（再試行できない）") {
    ScreenFailureView(
        failure: FetchFailure(
            "データを読み取れませんでした",
            canRetry: false
        )
    ) {}
}
