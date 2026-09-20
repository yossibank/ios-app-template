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
        return try await nextPage().value
    }

    func fetchMore() async throws -> FetchMore<[PokemonSummary]>? {
        try await nextPage()
    }

    private func nextPage() async throws -> FetchMore<[PokemonSummary]> {
        switch try await onEnum(of: dependency.paging.loadNext()) {
        case let .loaded(loaded):
            if loaded.hasMore {
                .more(loaded.pokemon)
            } else {
                .last(loaded.pokemon)
            }

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
        var paging: any PokemonPaging = PokemonPager()
    }
}

private extension PokemonListResultFailed {
    var asFetchFailure: FetchFailure {
        FetchFailure(message, canRetry: canRetry)
    }

    var message: String {
        switch onEnum(of: self) {
        case .offline:
            HomeStrings.offline

        case let .server(server):
            HomeStrings.serverError(statusCode: Int(server.statusCode))

        case .unexpected:
            HomeStrings.unreadable
        }
    }
}
