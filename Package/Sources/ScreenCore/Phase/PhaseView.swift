import SwiftUI

public struct PhaseView<Value, Success: View>: View {
    @Environment(\.phaseViewStyle) private var style

    private let phase: ScreenPhase<Value>
    private let success: (Value) -> Success
    private let retry: () -> Void

    public init(
        _ phase: ScreenPhase<Value>,
        @ViewBuilder success: @escaping (Value) -> Success,
        retry: @escaping () -> Void
    ) {
        self.phase = phase
        self.success = success
        self.retry = retry
    }

    public var body: some View {
        switch phase {
        case .idle, .loading:
            style.loading()

        case let .loaded(value):
            success(value)

        case let .failed(error):
            style.failure(
                PhaseViewStyle.Failure(
                    error: error,
                    retry: retry
                )
            )
        }
    }
}
