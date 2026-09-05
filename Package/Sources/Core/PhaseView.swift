import SwiftUI

/// 読み込み中と失敗の表示。各画面が書くのは成功時だけになる。
///
/// 見た目は `.phaseViewStyle(_:)` で差し替える。再試行は既定で
/// `ScreenModel.load()` に繋がり、`retry` を渡したときだけそちらを呼ぶ。
public struct PhaseView<Model: ScreenModel, Success: View>: View {
    @Environment(\.phaseViewStyle) private var style

    private let model: Model
    private let retry: (@MainActor () async -> Void)?
    private let success: (Model.Value) -> Success

    public init(
        _ model: Model,
        retry: (@MainActor () async -> Void)? = nil,
        @ViewBuilder success: @escaping (Model.Value) -> Success
    ) {
        self.model = model
        self.retry = retry
        self.success = success
    }

    public var body: some View {
        switch model.phase {
        case .loading:
            style.loading()

        case let .loaded(value):
            success(value)

        case let .failed(message):
            style.failure(
                PhaseFailure(
                    message: message,
                    retry: retry ?? { await model.load() }
                )
            )
        }
    }
}
