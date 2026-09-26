@MainActor
public struct ScreenSource<Model: ScreenViewModel> {
    enum Kind {
        case live(Model)
        case snapshot(FetchPhase<Model.Value>, loadingMore: Bool)
    }

    let kind: Kind

    public static func live(_ model: Model) -> Self {
        Self(kind: .live(model))
    }

    public static func snapshot(
        _ phase: FetchPhase<Model.Value>,
        loadingMore: Bool = false
    ) -> Self {
        Self(kind: .snapshot(phase, loadingMore: loadingMore))
    }
}
