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

    deinit {
        close()
    }
}

extension HomeViewModel {
    func fetch() async throws(FetchFailure) -> [PokemonEntry] {
        try await reset()

        switch try await outcome(of: { try await dependency.paging.loadNext() }) {
        case let .ready(pokemon, _):
            return pokemon

        case let .failed(failure):
            throw failure

        case .stale:
            return []
        }
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[PokemonEntry]>? {
        switch try await outcome(of: { try await dependency.paging.loadNext() }) {
        case let .ready(pokemon, hasMore):
            return hasMore ? .more(pokemon) : .last(pokemon)

        case let .failed(failure):
            note(failure)
            return nil

        case .stale:
            return nil
        }
    }

    func fetchRepaired() async throws(FetchFailure) -> [PokemonEntry]? {
        switch try await outcome(of: { try await dependency.paging.retryMissingDetails() }) {
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
        dependency.paging.close()
    }

    private func outcome(
        of operation: () async throws -> PokemonListResult
    ) async throws(FetchFailure) -> Outcome {
        let result: PokemonListResult

        do {
            result = try await operation()
        } catch {
            throw FetchFailure(HomeStrings.unexpected)
        }

        switch onEnum(of: result) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil, total: loaded.total)
            return .ready(pokemon: loaded.pokemon, hasMore: loaded.hasMore)

        case let .degraded(degraded):
            record(
                incomplete: degraded.incompleteCount,
                notice: degraded.failure.asFetchFailure,
                total: degraded.total
            )
            return .ready(pokemon: degraded.pokemon, hasMore: false)

        case let .failed(failed):
            return .failed(failed.failure.asFetchFailure)

        case .stale:
            return .stale
        }
    }

    private func record(incomplete: Int32, notice: FetchFailure?, total: Int32) {
        viewState.incompleteCount = Int(incomplete)
        viewState.notice = notice
        viewState.total = Int(total)
    }

    private func note(_ notice: FetchFailure?) {
        viewState.notice = notice
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
    private enum Outcome {
        case ready(pokemon: [PokemonEntry], hasMore: Bool)
        case failed(FetchFailure)
        case stale
    }

    @Observable
    final class State: ViewState {
        var query = ""
        var selectedType: PokemonTypeKind?
        var sort: PokemonSort = .number
        var total = 0
        var incompleteCount = 0
        var notice: FetchFailure?
    }

    struct Dependency {
        var paging: any PokemonPaging = PokemonPager()
    }
}

private extension PokemonFailure {
    var asFetchFailure: FetchFailure {
        FetchFailure(message, canRetry: canRetry)
    }

    var message: String {
        switch onEnum(of: self) {
        case .offline:
            HomeStrings.offline

        case .timeout:
            HomeStrings.timeout

        case let .server(server):
            HomeStrings.serverError(statusCode: Int(server.statusCode))

        case .unexpected:
            HomeStrings.unreadable

        case .closed:
            HomeStrings.unexpected
        }
    }
}
