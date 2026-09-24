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

        switch await outcome(of: dependency.listing.reload(), retry: .loadMore) {
        case let .ready(pokemon, _):
            return pokemon

        case let .failed(failure):
            throw failure

        case .stale:
            return []
        }
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[Pokemon]>? {
        viewState.notice = nil

        return await ready(from: dependency.listing.loadNext(), retry: .loadMore).map { page in
            page.hasMore ? .more(page.pokemon) : .last(page.pokemon)
        }
    }

    func update() async throws(FetchFailure) -> [Pokemon]? {
        viewState.notice = nil

        return await ready(from: dependency.listing.retryMissingDetails(), retry: .update)?.pokemon
    }

    nonisolated func close() {
        dependency.listing.close()
    }

    private func outcome(of page: PokemonListPage, retry: FetchOperation) -> Outcome {
        switch page {
        case let .loaded(snapshot):
            record(snapshot, notice: nil)
            return .ready(pokemon: snapshot.pokemon, hasMore: snapshot.hasMore)

        case let .degraded(snapshot, failure):
            record(snapshot, notice: Notice(failure: failure.asFetchFailure, retry: retry))
            return .ready(pokemon: snapshot.pokemon, hasMore: snapshot.hasMore)

        case let .failed(failure):
            return .failed(failure.asFetchFailure)

        case .stale:
            return .stale
        }
    }

    private func ready(
        from page: PokemonListPage,
        retry: FetchOperation
    ) -> (pokemon: [Pokemon], hasMore: Bool)? {
        switch outcome(of: page, retry: retry) {
        case let .ready(pokemon, hasMore):
            return (pokemon, hasMore)

        case let .failed(failure):
            viewState.notice = Notice(failure: failure, retry: retry)
            return nil

        case .stale:
            return nil
        }
    }

    private func record(_ snapshot: PokemonListSnapshot, notice: Notice?) {
        viewState.incompleteCount = snapshot.incompleteCount
        viewState.notice = notice
        viewState.total = snapshot.total
    }
}

extension HomeViewModel {
    private enum Outcome {
        case ready(pokemon: [Pokemon], hasMore: Bool)
        case failed(FetchFailure)
        case stale
    }

    struct Notice {
        let failure: FetchFailure
        let retry: FetchOperation
    }

    @Observable
    final class State: ViewState {
        var query = ""
        var selectedType: PokemonType?
        var sort: PokemonSort = .number
        var route: HomeRoute?
        var total = 0
        var incompleteCount = 0
        var notice: Notice?
    }

    struct Dependency {
        var listing: any PokemonListing = PokemonPagerListing()
    }
}

private extension PokemonLoadFailure {
    var asFetchFailure: FetchFailure {
        FetchFailure(message, canRetry: canRetry)
    }

    var message: String {
        switch reason {
        case .offline:
            HomeStrings.offline

        case .timeout:
            HomeStrings.timeout

        case let .server(statusCode):
            HomeStrings.serverError(statusCode: statusCode)

        case .unreadable:
            HomeStrings.unreadable

        case .closed, .interrupted:
            HomeStrings.unexpected
        }
    }
}
