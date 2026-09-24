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
        switch await outcome(of: dependency.listing.reload()) {
        case let .ready(pokemon, _):
            return pokemon

        case let .failed(failure):
            throw failure

        case .stale:
            return []
        }
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[Pokemon]>? {
        switch await outcome(of: dependency.listing.loadNext()) {
        case let .ready(pokemon, hasMore):
            return hasMore ? .more(pokemon) : .last(pokemon)

        case let .failed(failure):
            note(failure)
            return nil

        case .stale:
            return nil
        }
    }

    func fetchRepaired() async throws(FetchFailure) -> [Pokemon]? {
        switch await outcome(of: dependency.listing.retryMissingDetails()) {
        case let .ready(pokemon, _):
            return pokemon

        case let .failed(failure):
            note(failure)
            return nil

        case .stale:
            return nil
        }
    }

    nonisolated func close() {
        dependency.listing.close()
    }

    private func outcome(of page: PokemonListPage) -> Outcome {
        switch page {
        case let .loaded(snapshot):
            record(snapshot, notice: nil)
            return .ready(pokemon: snapshot.pokemon, hasMore: snapshot.hasMore)

        case let .degraded(snapshot, failure):
            record(snapshot, notice: failure.asFetchFailure)
            return .ready(pokemon: snapshot.pokemon, hasMore: false)

        case let .failed(failure):
            return .failed(failure.asFetchFailure)

        case .stale:
            return .stale
        }
    }

    private func record(_ snapshot: PokemonListSnapshot, notice: FetchFailure?) {
        viewState.incompleteCount = snapshot.incompleteCount
        viewState.notice = notice
        viewState.total = snapshot.total
    }

    private func note(_ notice: FetchFailure?) {
        viewState.notice = notice
    }
}

extension HomeViewModel {
    private enum Outcome {
        case ready(pokemon: [Pokemon], hasMore: Bool)
        case failed(FetchFailure)
        case stale
    }

    @Observable
    final class State: ViewState {
        var query = ""
        var selectedType: PokemonType?
        var sort: PokemonSort = .number
        var route: HomeRoute?
        var total = 0
        var incompleteCount = 0
        var notice: FetchFailure?
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
