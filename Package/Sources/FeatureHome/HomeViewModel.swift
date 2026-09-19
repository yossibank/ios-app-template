import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel: ScreenViewModel {
    let viewState = State()
    let fetchState = FetchState<[PokemonSummary]>()
    let dependency: Dependency

    convenience init() {
        self.init(dependency: .init())
    }

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension HomeViewModel {
    func fetch() async throws -> [PokemonSummary] {
        try await dependency.paging.reset()
        return try await nextPage()
    }

    func fetchMore() async throws -> [PokemonSummary]? {
        guard viewState.hasMore else {
            return nil
        }

        return try await nextPage()
    }

    private func nextPage() async throws -> [PokemonSummary] {
        switch try await onEnum(of: dependency.paging.loadNext()) {
        case let .loaded(loaded):
            viewState.hasMore = loaded.hasMore
            return loaded.pokemon

        case let .failed(failed):
            throw failed.asFetchFailure
        }
    }
}

extension HomeViewModel {
    @Observable
    final class State: ViewState {
        var query = ""
        var hasMore = true
    }

    struct Dependency {
        var paging: any PokemonPaging = PokemonPager()
    }
}

private extension PokemonListResultFailed {
    var asFetchFailure: FetchFailure {
        switch onEnum(of: self) {
        case .offline:
            FetchFailure("接続を確認してください")

        case let .server(server):
            FetchFailure("サーバーが応答しませんでした（\(server.statusCode)）")

        case .unexpected:
            FetchFailure("データを読み取れませんでした", canRetry: false)
        }
    }
}
