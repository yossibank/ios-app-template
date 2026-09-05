import SwiftUI

@MainActor
public enum ScreenSource<Model: ScreenViewModel> {
    case live(Model)
    case snapshot(FetchPhase<Model.Value>)
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
        PhaseContent(model.fetchState.phase) {
            success(model.viewState, $0)
        }
        .environment(
            \.screenReload,
            ScreenReloadAction {
                model.reload()
            }
        )
        .task(id: model.fetchState.reloadID) {
            await model.load()
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Success: View>: View {
    @State private var viewState = Model.State()

    private let phase: FetchPhase<Model.Value>
    private let success: (Model.State, Model.Value) -> Success

    init(
        _ phase: FetchPhase<Model.Value>,
        @ViewBuilder success: @escaping (Model.State, Model.Value) -> Success
    ) {
        self.phase = phase
        self.success = success
    }

    var body: some View {
        PhaseContent(phase) {
            success(viewState, $0)
        }
    }
}

private struct PhaseContent<Value, Success: View>: View {
    @Environment(\.screenStyle) private var style
    @Environment(\.screenReload) private var reload

    private let phase: FetchPhase<Value>
    private let success: (Value) -> Success

    init(
        _ phase: FetchPhase<Value>,
        @ViewBuilder success: @escaping (Value) -> Success
    ) {
        self.phase = phase
        self.success = success
    }

    var body: some View {
        switch phase {
        case .idle, .loading:
            style.loading()

        case let .loaded(value):
            success(value)

        case let .failed(error):
            style.failure(
                ScreenStyle.Failure(error: error) { reload() }
            )
        }
    }
}
