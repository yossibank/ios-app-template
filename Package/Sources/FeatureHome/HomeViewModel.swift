import Core
import Observation

@MainActor
@Observable
public final class HomeViewModel: ScreenModel {
    public private(set) var phase: Phase<[PokemonSummary]> = .loading
    public var destination: NoDestination?

    /// スタブでは nil。`load()` は状態を触らずに戻る。
    private let fetchPage: ((Int32, Int32) async -> PokemonListResult?)?

    /// 失敗は Failed として返るため、throw はキャンセル時だけ。
    public init(
        fetchPage: @escaping (Int32, Int32) async -> PokemonListResult? = {
            try? await PokemonApi().fetchPage(limit: $0, offset: $1)
        }
    ) {
        self.fetchPage = fetchPage
    }

    /// プレビューとテスト用。通信せずに状態だけを固定する。
    public init(phase: Phase<[PokemonSummary]>) {
        self.phase = phase
        self.fetchPage = nil
    }

    public func load() async {
        guard let fetchPage else {
            return
        }

        phase = .loading

        guard let result = await fetchPage(Self.pageSize, 0) else {
            return
        }

        switch onEnum(of: result) {
        case let .loaded(loaded):
            phase = .loaded(loaded.pokemon)

        case let .failed(failed):
            phase = .failed(failed.message)
        }
    }

    private static let pageSize: Int32 = 20
}
