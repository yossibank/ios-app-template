@MainActor
public struct ScreenSource<Model: ScreenViewModel> {
    let kind: Kind
}

public extension ScreenSource {
    static func live(_ model: Model) -> Self {
        let kind = Kind.live(model)
        return Self(kind: kind)
    }

    static func snapshot(
        _ phase: FetchPhase<Model.Value>,
        loadingMore: Bool = false
    ) -> Self {
        let kind = Kind.snapshot(phase, loadingMore: loadingMore)
        return Self(kind: kind)
    }
}

extension ScreenSource {
    enum Kind {
        case live(Model)
        case snapshot(FetchPhase<Model.Value>, loadingMore: Bool)
    }
}
