import SwiftUI

/// 読み込み中と失敗の表示。各画面が書くのは成功時だけになる。
///
/// モデルを直接受け取るため、再試行は必ず `ScreenModel.load()` に繋がる。
public struct PhaseView<Model: ScreenModel, Success: View>: View {
    private let model: Model
    private let success: (Model.Value) -> Success

    public init(
        _ model: Model,
        @ViewBuilder success: @escaping (Model.Value) -> Success
    ) {
        self.model = model
        self.success = success
    }

    public var body: some View {
        switch model.phase {
        case .loading:
            ProgressView()

        case let .loaded(value):
            success(value)

        case let .failed(message):
            ContentUnavailableView {
                Label("読み込めませんでした", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("再試行") {
                    Task { await model.load() }
                }
            }
        }
    }
}
