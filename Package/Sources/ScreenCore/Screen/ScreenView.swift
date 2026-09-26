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
public struct ScreenView<
    Model: ScreenViewModel,
    Success: View,
    EmptyContent: View,
    Loading: View
>: View {
    private let source: ScreenSource<Model>
    private let isEmpty: (Model.Value) -> Bool
    private let success: (Model.State, Model.Value, ScreenActions) -> Success
    private let empty: (ScreenActions) -> EmptyContent
    private let loading: () -> Loading

    public init(
        _ source: ScreenSource<Model>,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent,
        @ViewBuilder loading: @escaping () -> Loading
    ) {
        self.source = source
        self.isEmpty = isEmpty
        self.success = success
        self.empty = empty
        self.loading = loading
    }

    public var body: some View {
        switch source.kind {
        case let .live(model):
            LiveScreen(model, content: content)

        case let .snapshot(phase, running):
            SnapshotScreen<Model, _>(phase: phase, running: running, content: content)
        }
    }

    @ViewBuilder
    private func content(
        phase: FetchPhase<Model.Value>,
        viewState: Model.State,
        actions: ScreenActions
    ) -> some View {
        switch phase {
        case .idle, .loading:
            loading()

        case let .loaded(value):
            if isEmpty(value) {
                empty(actions)
            } else {
                success(viewState, value, actions)
            }

        case let .failed(failure):
            ScreenFailureView(failure: failure) {
                actions.request(.reload)
            }
        }
    }
}

public extension ScreenView where EmptyContent == EmptyView {
    init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder loading: @escaping () -> Loading
    ) {
        self.init(
            source,
            isEmpty: { _ in false },
            success: success,
            empty: { _ in EmptyView() },
            loading: loading
        )
    }
}

public extension ScreenView where Model.Value: Collection {
    init(
        _ source: ScreenSource<Model>,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent,
        @ViewBuilder loading: @escaping () -> Loading
    ) {
        self.init(
            source,
            isEmpty: \.isEmpty,
            success: success,
            empty: empty,
            loading: loading
        )
    }
}

@MainActor
private struct LiveScreen<Model: ScreenViewModel, Content: View>: View {
    @State private var model: Model

    private let content: (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content

    init(
        _ model: Model,
        content: @escaping (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content
    ) {
        _model = State(initialValue: model)
        self.content = content
    }

    var body: some View {
        content(
            model.fetchState.phase,
            model.viewState,
            ScreenActions(
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
private struct SnapshotScreen<Model: ScreenViewModel, Content: View>: View {
    @State private var viewState: Model.State

    private let phase: FetchPhase<Model.Value>
    private let running: Set<FetchOperation>
    private let content: (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content

    init(
        phase: FetchPhase<Model.Value>,
        running: Set<FetchOperation>,
        content: @escaping (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content
    ) {
        _viewState = State(initialValue: Model.State())
        self.phase = phase
        self.running = running
        self.content = content
    }

    var body: some View {
        content(
            phase,
            viewState,
            ScreenActions(
                request: { _ in },
                refresh: {},
                isRunning: { running.contains($0) }
            )
        )
    }
}
