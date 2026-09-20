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
public struct ScreenView<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    private let source: ScreenSource<Model>
    private let isEmpty: (Model.Value) -> Bool
    private let success: (Model.State, Model.Value, ScreenActions) -> Success
    private let empty: (ScreenActions) -> EmptyContent

    public init(
        _ source: ScreenSource<Model>,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        self.source = source
        self.isEmpty = isEmpty
        self.success = success
        self.empty = empty
    }

    public var body: some View {
        switch source.kind {
        case let .live(model):
            LiveScreen(
                model,
                isEmpty: isEmpty,
                success: success,
                empty: empty
            )

        case let .snapshot(phase):
            SnapshotScreen<Model, Success, EmptyContent>(
                phase: phase,
                isEmpty: isEmpty,
                success: success,
                empty: empty
            )
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
private struct LiveScreen<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    @State private var model: Model

    private let isEmpty: (Model.Value) -> Bool
    private let success: (Model.State, Model.Value, ScreenActions) -> Success
    private let empty: (ScreenActions) -> EmptyContent

    init(
        _ model: Model,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        _model = State(initialValue: model)
        self.isEmpty = isEmpty
        self.success = success
        self.empty = empty
    }

    var body: some View {
        PhaseContent(
            phase: model.fetchState.phase,
            isEmpty: isEmpty,
            reload: { model.reload() },
            loadMore: { model.requestLoadMore() },
            success: { value, actions in
                success(model.viewState, value, actions)
            },
            empty: empty
        )
        .task(id: model.fetchState.reloadID) {
            await model.load()
        }
        .task(id: model.fetchState.loadMoreID) {
            await model.loadMore()
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    @State private var viewState: Model.State

    private let phase: FetchPhase<Model.Value>
    private let isEmpty: (Model.Value) -> Bool
    private let success: (Model.State, Model.Value, ScreenActions) -> Success
    private let empty: (ScreenActions) -> EmptyContent

    init(
        phase: FetchPhase<Model.Value>,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        _viewState = State(initialValue: Model.State())
        self.phase = phase
        self.isEmpty = isEmpty
        self.success = success
        self.empty = empty
    }

    var body: some View {
        PhaseContent(
            phase: phase,
            isEmpty: isEmpty,
            reload: {},
            loadMore: {},
            success: { value, actions in
                success(viewState, value, actions)
            },
            empty: empty
        )
    }
}

@MainActor
private struct PhaseContent<Value, Success: View, EmptyContent: View>: View {
    @Environment(\.screenStyle) private var style

    private var actions: ScreenActions {
        ScreenActions(
            reload: reload,
            loadMore: loadMore,
            isLoadingMore: phase.isLoadingMore
        )
    }

    let phase: FetchPhase<Value>
    let isEmpty: (Value) -> Bool
    let reload: @MainActor () -> Void
    let loadMore: @MainActor () -> Void
    @ViewBuilder let success: (Value, ScreenActions) -> Success
    @ViewBuilder let empty: (ScreenActions) -> EmptyContent

    var body: some View {
        switch phase {
        case .idle, .loading:
            style.loading()

        case let .loaded(value), let .loadingMore(value):
            if isEmpty(value) {
                empty(actions)
            } else {
                success(value, actions)
            }

        case let .failed(failure):
            style.failure(
                ScreenStyle.Failure(error: failure, retry: reload)
            )
        }
    }
}
