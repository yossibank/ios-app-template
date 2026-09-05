import SwiftUI

@MainActor
public enum ScreenSource<Model: ScreenViewModel> {
    case live(Model)
    case snapshot(ScreenPhase<Model.Value>)
}

@MainActor
public struct ScreenView<Model: ScreenViewModel, Success: View>: View {
    private let source: ScreenSource<Model>
    private let success: (Model.State, Model.Value) -> Success

    public init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.State, Model.Value) -> Success
    ) {
        self.source = source
        self.success = success
    }

    public init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.Value) -> Success
    ) {
        self.source = source
        self.success = { _, value in success(value) }
    }

    public var body: some View {
        switch source {
        case let .live(model):
            LiveScreen(model, success: success)

        case let .snapshot(phase):
            SnapshotScreen<Model, Success>(phase, success: success)
        }
    }
}

@MainActor
private struct LiveScreen<Model: ScreenViewModel, Success: View>: View {
    @State private var model: Model

    private let success: (Model.State, Model.Value) -> Success

    init(
        _ model: Model,
        @ViewBuilder success: @escaping (Model.State, Model.Value) -> Success
    ) {
        _model = State(initialValue: model)
        self.success = success
    }

    var body: some View {
        PhaseView(
            model.phase,
            success: { success(model.state, $0) },
            retry: model.reload
        )
        .environment(\.screenReload, ScreenReloadAction { model.reload() })
        .task(id: model.screen.reloadID) {
            await model.load()
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Success: View>: View {
    @State private var state = Model.State()

    private let phase: ScreenPhase<Model.Value>
    private let success: (Model.State, Model.Value) -> Success

    init(
        _ phase: ScreenPhase<Model.Value>,
        @ViewBuilder success: @escaping (Model.State, Model.Value) -> Success
    ) {
        self.phase = phase
        self.success = success
    }

    var body: some View {
        PhaseView(
            phase,
            success: { success(state, $0) },
            retry: {}
        )
    }
}
