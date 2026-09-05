import SwiftUI

public struct PhaseViewStyle {
    public struct Failure {
        public let error: any Error
        public let retry: () -> Void

        public var message: String {
            error.localizedDescription
        }
    }

    let loading: () -> AnyView
    let failure: (Failure) -> AnyView

    public init<Loading: View, FailureBody: View>(
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder failure: @escaping (Failure) -> FailureBody
    ) {
        self.loading = {
            AnyView(loading())
        }

        self.failure = {
            AnyView(failure($0))
        }
    }

    public static var standard: PhaseViewStyle {
        PhaseViewStyle(
            loading: {
                ProgressView()
            },
            failure: { failure in
                ContentUnavailableView {
                    Label("読み込めませんでした", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(failure.message)
                } actions: {
                    Button("再試行", action: failure.retry)
                }
            }
        )
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
