import SwiftUI

@MainActor
public struct ScreenSource<Model: ScreenViewModel> {
    enum Kind {
        case live(Model)
        case snapshot(FetchPhase<Model.Value>)
    }

    let kind: Kind

    public static func live(_ model: Model) -> Self {
        Self(kind: .live(model))
    }

    public static func snapshot(_ phase: FetchPhase<Model.Value>) -> Self {
        Self(kind: .snapshot(phase))
    }
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

    public var body: some View {
        switch source.kind {
        case let .live(model):
            LiveScreen(model, success: success)

        case let .snapshot(phase):
            SnapshotScreen<Model, Success>(phase: phase, success: success)
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
        PhaseContent(phase: model.fetchState.phase) {
            success(model.viewState, $0)
        }
        .environment(\.screenReload) {
            model.reload()
        }
        .task(id: model.fetchState.reloadID) {
            await model.load()
        }
    }
}

private struct SnapshotScreen<Model: ScreenViewModel, Success: View>: View {
    @State private var viewState = Model.State()

    let phase: FetchPhase<Model.Value>
    let success: (Model.State, Model.Value) -> Success

    var body: some View {
        PhaseContent(phase: phase) {
            success(viewState, $0)
        }
    }
}

private struct PhaseContent<Value, Success: View>: View {
    @Environment(\.screenStyle) private var style
    @Environment(\.screenReload) private var reload

    let phase: FetchPhase<Value>
    let success: (Value) -> Success

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
