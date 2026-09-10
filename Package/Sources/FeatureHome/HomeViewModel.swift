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
        let result = try await dependency.api.fetchPage(limit: 20, offset: 0)

        switch onEnum(of: result) {
        case let .loaded(loaded):
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
    }

    struct Dependency {
        var api: any PokemonFetching = PokemonApi()
    }
}

private extension PokemonListResultFailed {
    var asFetchFailure: FetchFailure {
        switch onEnum(of: self) {
        case .offline:
            FetchFailure("接続を確認してください")

        case let .server(server):
            FetchFailure("サーバーが応答しませんでした（\(server.statusCode)）")

        case .unexpected, .legacy:
            FetchFailure("データを読み取れませんでした", canRetry: false)
        }
    }
}
