import SwiftUI

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

        case let .snapshot(phase, loadingMore):
            SnapshotScreen<Model, _>(phase: phase, loadingMore: loadingMore, content: content)
        }
    }
}

private extension ScreenView {
    @ViewBuilder
    func content(
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
            ScreenFailureView(failure: failure, retry: actions.reload)
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
    @Environment(\.onSessionEnded) private var onSessionEnded

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
                reload: { model.reload() },
                loadMore: { model.loadMore() },
                refresh: { await model.refresh() },
                isLoadingMore: model.fetchState.isRunning(.loadMore)
            )
        )
        .task {
            model.start()
        }
        .onChange(of: model.fetchState.sessionEnded) { _, ended in
            if ended {
                onSessionEnded()
            }
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Content: View>: View {
    @State private var viewState: Model.State

    private let phase: FetchPhase<Model.Value>
    private let loadingMore: Bool
    private let content: (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content

    init(
        phase: FetchPhase<Model.Value>,
        loadingMore: Bool,
        content: @escaping (FetchPhase<Model.Value>, Model.State, ScreenActions) -> Content
    ) {
        _viewState = State(initialValue: Model.State())
        self.phase = phase
        self.loadingMore = loadingMore
        self.content = content
    }

    var body: some View {
        content(
            phase,
            viewState,
            ScreenActions(
                reload: {},
                loadMore: {},
                refresh: {},
                isLoadingMore: loadingMore
            )
        )
    }
}
