import SwiftUI

/// 失敗表示に渡る情報。
public struct PhaseFailure: Sendable {
    public let message: String
    public let retry: @MainActor () async -> Void
}

/// `PhaseView` の読み込み中と失敗の見た目。
///
/// 既定を全画面で共有し、変えたい範囲にだけ `.phaseViewStyle(_:)` を付ける。
/// `ButtonStyle` などと同じ作法にしてあるので、差し替えの範囲が
/// modifier を付けた階層に閉じる。
public struct PhaseViewStyle {
    let loading: () -> AnyView
    let failure: (PhaseFailure) -> AnyView

    public init<Loading: View, Failure: View>(
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder failure: @escaping (PhaseFailure) -> Failure
    ) {
        self.loading = { AnyView(loading()) }
        self.failure = { AnyView(failure($0)) }
    }

    public static var standard: PhaseViewStyle {
        PhaseViewStyle {
            ProgressView()
        } failure: { failure in
            ContentUnavailableView {
                Label("読み込めませんでした", systemImage: "exclamationmark.triangle")
            } description: {
                Text(failure.message)
            } actions: {
                Button("再試行") {
                    Task { await failure.retry() }
                }
            }
        }
    }
}

public extension EnvironmentValues {
    @Entry var phaseViewStyle: PhaseViewStyle = .standard
}

public extension View {
    func phaseViewStyle(_ style: PhaseViewStyle) -> some View {
        environment(\.phaseViewStyle, style)
    }
}
