import SwiftUI

public struct ScreenStyle {
    public struct Failure {
        public let error: any Error
        public let retry: () -> Void

        public var message: String {
            (error as? FetchFailure)?.message ?? ScreenStrings.unexpectedError
        }

        public var canRetry: Bool {
            (error as? FetchFailure)?.canRetry ?? true
        }
    }

    let loading: () -> AnyView
    let failure: (Failure) -> AnyView

    public init(
        @ViewBuilder loading: @escaping () -> some View,
        @ViewBuilder failure: @escaping (Failure) -> some View
    ) {
        self.loading = {
            AnyView(loading())
        }

        self.failure = {
            AnyView(failure($0))
        }
    }

    public static var standard: ScreenStyle {
        ScreenStyle(
            loading: {
                ProgressView()
            },
            failure: { failure in
                ContentUnavailableView {
                    Label(
                        ScreenStrings.loadFailed,
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(failure.message)
                } actions: {
                    if failure.canRetry {
                        Button(
                            ScreenStrings.retry,
                            action: failure.retry
                        )
                    }
                }
            }
        )
    }
}

public extension EnvironmentValues {
    @Entry var screenStyle: ScreenStyle = .standard
}

public extension View {
    func screenStyle(_ style: ScreenStyle) -> some View {
        environment(\.screenStyle, style)
    }
}

#Preview("読み込み中") {
    ScreenStyle.standard.loading()
}

#Preview("失敗") {
    ScreenStyle.standard.failure(
        ScreenStyle.Failure(
            error: FetchFailure("ネットワークに接続できません")
        ) {}
    )
}

#Preview("失敗（再試行できない）") {
    ScreenStyle.standard.failure(
        ScreenStyle.Failure(
            error: FetchFailure(
                "データを読み取れませんでした",
                canRetry: false
            )
        ) {}
    )
}
