import SwiftUI

@MainActor
public struct ScreenSource<Model: ScreenViewModel> {
    enum Kind {
        case live(Model)
        case snapshot(FetchPhase<Model.Value>, running: Set<FetchOperation>)
    }

    let kind: Kind

    public static func live(_ model: Model) -> Self {
        Self(kind: .live(model))
    }

    public static func snapshot(
        _ phase: FetchPhase<Model.Value>,
        running: Set<FetchOperation> = []
    ) -> Self {
        Self(kind: .snapshot(phase, running: running))
    }
}

@MainActor
public struct ScreenView<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    private let source: ScreenSource<Model>
    private let content: ScreenContent<Model, Success, EmptyContent>

    public init(
        _ source: ScreenSource<Model>,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        self.source = source
        self.content = ScreenContent(isEmpty: isEmpty, success: success, empty: empty)
    }

    public var body: some View {
        switch source.kind {
        case let .live(model):
            LiveScreen(model, content: content)

        case let .snapshot(phase, running):
            SnapshotScreen(phase: phase, running: running, content: content)
        }
    }
}

public extension ScreenView where EmptyContent == EmptyView {
    init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success
    ) {
        self.init(
            source,
            isEmpty: { _ in false },
            success: success,
            empty: { _ in EmptyView() }
        )
    }
}

public extension ScreenView where Model.Value: Collection {
    init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        self.init(
            source,
            isEmpty: \.isEmpty,
            success: success,
            empty: empty
        )
    }
}

@MainActor
private struct ScreenContent<Model: ScreenViewModel, Success: View, EmptyContent: View> {
    let isEmpty: (Model.Value) -> Bool
    let success: (Model.State, Model.Value, ScreenActions) -> Success
    let empty: (ScreenActions) -> EmptyContent

    func body(
        phase: FetchPhase<Model.Value>,
        viewState: Model.State,
        actions: ScreenActions
    ) -> PhaseContent<Model.Value, Success, EmptyContent> {
        PhaseContent(
            phase: phase,
            isEmpty: isEmpty,
            actions: actions,
            success: { value, actions in
                success(viewState, value, actions)
            },
            empty: empty
        )
    }
}

@MainActor
private struct LiveScreen<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    @State private var model: Model

    private let content: ScreenContent<Model, Success, EmptyContent>

    init(_ model: Model, content: ScreenContent<Model, Success, EmptyContent>) {
        _model = State(initialValue: model)
        self.content = content
    }

    var body: some View {
        content.body(
            phase: model.fetchState.phase,
            viewState: model.viewState,
            actions: ScreenActions(
                request: { model.request($0) },
                refresh: { await model.refresh() },
                isRunning: { model.fetchState.isRunning($0) }
            )
        )
        .task {
            model.start()
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    @State private var viewState: Model.State

    private let phase: FetchPhase<Model.Value>
    private let running: Set<FetchOperation>
    private let content: ScreenContent<Model, Success, EmptyContent>

    init(
        phase: FetchPhase<Model.Value>,
        running: Set<FetchOperation>,
        content: ScreenContent<Model, Success, EmptyContent>
    ) {
        _viewState = State(initialValue: Model.State())
        self.phase = phase
        self.running = running
        self.content = content
    }

    var body: some View {
        content.body(
            phase: phase,
            viewState: viewState,
            actions: ScreenActions(
                request: { _ in },
                refresh: {},
                isRunning: { running.contains($0) }
            )
        )
    }
}

@MainActor
private struct PhaseContent<Value, Success: View, EmptyContent: View>: View {
    @Environment(\.screenStyle) private var style

    let phase: FetchPhase<Value>
    let isEmpty: (Value) -> Bool
    let actions: ScreenActions
    @ViewBuilder let success: (Value, ScreenActions) -> Success
    @ViewBuilder let empty: (ScreenActions) -> EmptyContent

    var body: some View {
        switch phase {
        case .idle, .loading:
            style.loading()

        case let .loaded(value):
            if isEmpty(value) {
                empty(actions)
            } else {
                success(value, actions)
            }

        case let .failed(failure):
            style.failure(
                ScreenStyle.Failure(error: failure) {
                    actions.request(.reload)
                }
            )
        }
    }
}
