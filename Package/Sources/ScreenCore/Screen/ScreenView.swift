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

        case let .snapshot(phase, running):
            SnapshotScreen<Model, Success, EmptyContent>(
                phase: phase,
                running: running,
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
            actions: ScreenActions(
                request: { model.request($0) },
                refresh: { await model.refresh() },
                isRunning: { model.fetchState.isRunning($0) }
            ),
            success: { value, actions in
                success(model.viewState, value, actions)
            },
            empty: empty
        )
        .task(id: model.fetchState.id(of: .reload)) {
            await model.run(.reload)
        }
        .task(id: model.fetchState.id(of: .loadMore)) {
            await model.run(.loadMore)
        }
        .task(id: model.fetchState.id(of: .refill)) {
            await model.run(.refill)
        }
    }
}

@MainActor
private struct SnapshotScreen<Model: ScreenViewModel, Success: View, EmptyContent: View>: View {
    @State private var viewState: Model.State

    private let phase: FetchPhase<Model.Value>
    private let running: Set<FetchOperation>
    private let isEmpty: (Model.Value) -> Bool
    private let success: (Model.State, Model.Value, ScreenActions) -> Success
    private let empty: (ScreenActions) -> EmptyContent

    init(
        phase: FetchPhase<Model.Value>,
        running: Set<FetchOperation>,
        isEmpty: @escaping (Model.Value) -> Bool,
        @ViewBuilder success: @escaping (Model.State, Model.Value, ScreenActions) -> Success,
        @ViewBuilder empty: @escaping (ScreenActions) -> EmptyContent
    ) {
        _viewState = State(initialValue: Model.State())
        self.phase = phase
        self.running = running
        self.isEmpty = isEmpty
        self.success = success
        self.empty = empty
    }

    var body: some View {
        PhaseContent(
            phase: phase,
            isEmpty: isEmpty,
            actions: ScreenActions(
                request: { _ in },
                refresh: {},
                isRunning: { running.contains($0) }
            ),
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
