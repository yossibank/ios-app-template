import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel: ScreenViewModel {
    let viewState = State()
    let fetchState = FetchState<[Pokemon]>()
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
    func fetch() async throws(FetchFailure) -> [Pokemon] {
        viewState.notice = nil

        let page = await dependency.listing.reload()

        if case let .failed(failure) = page {
            throw failure
        }

        return snapshot(of: page)?.pokemon ?? []
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[Pokemon]>? {
        viewState.notice = nil

        return await snapshot(of: dependency.listing.loadNext()).map { snapshot in
            snapshot.hasMore ? .more(snapshot.pokemon) : .last(snapshot.pokemon)
        }
    }

    nonisolated func close() {
        dependency.listing.close()
    }

    private func snapshot(of page: PokemonListPage) -> PokemonListSnapshot? {
        switch page {
        case let .loaded(snapshot):
            viewState.total = snapshot.total
            return snapshot

        case let .degraded(snapshot, failure):
            viewState.total = snapshot.total
            viewState.notice = failure
            return snapshot

        case let .failed(failure):
            viewState.notice = failure
            return nil

        case .stale:
            return nil
        }
    }
}

extension HomeViewModel {
    @Observable
    final class State: ViewState {
        var query = ""
        var sort: PokemonSort = .number
        var total = 0
        var notice: FetchFailure?
    }

    struct Dependency {
        var listing: any PokemonListing = PokemonPagerListing()
    }
}
