import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel: ScreenViewModel {
    let viewState = State()
    let fetchState = FetchState<[PokemonEntry]>()
    let dependency: Dependency

    convenience init() {
        self.init(dependency: .init())
    }

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension HomeViewModel {
    func fetch() async throws(FetchFailure) -> [PokemonEntry] {
        try await reset()

        let result = try await nextPage()

        if let failure = result.failure, result.pokemon.isEmpty {
            throw failure.asFetchFailure
        }

        return result.pokemon
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[PokemonEntry]>? {
        let result = try await nextPage()

        return result.hasMore ? .more(result.pokemon) : .last(result.pokemon)
    }

    private func nextPage() async throws(FetchFailure) -> PokemonListResult {
        do {
            return try await dependency.paging.loadNext()
        } catch {
            throw FetchFailure(HomeStrings.unexpected)
        }
    }

    private func reset() async throws(FetchFailure) {
        do {
            try await dependency.paging.reset()
        } catch {
            throw FetchFailure(HomeStrings.unexpected)
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

private extension PokemonListFailure {
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
