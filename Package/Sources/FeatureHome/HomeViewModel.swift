import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel: ScreenViewModel {
    let viewState = State()
    let fetchState = FetchState<PokemonList>()
    let dependency: Dependency

    convenience init() {
        self.init(dependency: .init())
    }

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    deinit {
        close()
    }
}

extension HomeViewModel {
    func fetch() async throws(FetchFailure) -> PokemonList {
        switch await dependency.listing.reload() {
        case let .loaded(snapshot):
            PokemonList(snapshot)

        case let .degraded(snapshot, failure):
            PokemonList(snapshot, notice: failure)

        case let .failed(failure):
            throw failure

        case .stale:
            PokemonList(pokemon: [], total: 0)
        }
    }

    func fetchMore(after current: PokemonList) async throws(FetchFailure)
        -> FetchMore<PokemonList> {
        switch await dependency.listing.loadNext() {
        case let .loaded(snapshot):
            page(PokemonList(snapshot), hasMore: snapshot.hasMore)

        case let .degraded(snapshot, failure):
            page(PokemonList(snapshot, notice: failure), hasMore: snapshot.hasMore)

        case let .failed(failure):
            .more(PokemonList(pokemon: current.pokemon, total: current.total, notice: failure))

        case .stale:
            .unchanged
        }
    }

    nonisolated func close() {
        dependency.listing.close()
    }

    private func page(_ list: PokemonList, hasMore: Bool) -> FetchMore<PokemonList> {
        hasMore ? .more(list) : .last(list)
    }
}

extension HomeViewModel {
    @Observable
    final class State: ScreenViewState {
        var query = ""
    }

    struct Dependency {
        var listing: any PokemonListing = PokemonPagerListing()
    }
}
