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

        let outcome = try await result(of: { try await dependency.paging.loadNext() })

        switch onEnum(of: outcome) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil, total: loaded.total)
            return loaded.pokemon

        case let .degraded(degraded):
            record(
                incomplete: degraded.incompleteCount,
                notice: degraded.failure.asFetchFailure,
                total: degraded.total
            )
            return degraded.pokemon

        case let .failed(failed):
            throw failed.failure.asFetchFailure

        case .stale:
            return []
        }
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[PokemonEntry]>? {
        let outcome = try await result(of: { try await dependency.paging.loadNext() })

        switch onEnum(of: outcome) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil, total: loaded.total)
            return loaded.hasMore ? .more(loaded.pokemon) : .last(loaded.pokemon)

        case let .degraded(degraded):
            record(
                incomplete: degraded.incompleteCount,
                notice: degraded.failure.asFetchFailure,
                total: degraded.total
            )
            return .last(degraded.pokemon)

        case let .failed(failed):
            note(failed.failure.asFetchFailure)
            return nil

        case .stale:
            return nil
        }
    }

    func fetchRefilled() async throws(FetchFailure) -> [PokemonEntry]? {
        let outcome = try await result(of: { try await dependency.paging.retryMissingDetails() })

        switch onEnum(of: outcome) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil, total: loaded.total)
            return loaded.pokemon

        case let .degraded(degraded):
            record(
                incomplete: degraded.incompleteCount,
                notice: degraded.failure.asFetchFailure,
                total: degraded.total
            )
            return degraded.pokemon

        case let .failed(failed):
            note(failed.failure.asFetchFailure)
            return nil

        case .stale:
            return nil
        }
    }

    func close() {
        dependency.paging.close()
    }

    private func record(incomplete: Int32, notice: FetchFailure?, total: Int32) {
        viewState.incompleteCount = Int(incomplete)
        viewState.notice = notice
        viewState.total = Int(total)
    }

    private func note(_ notice: FetchFailure?) {
        viewState.notice = notice
    }

    private func result(
        of operation: () async throws -> PokemonListResult
    ) async throws(FetchFailure) -> PokemonListResult {
        do {
            return try await operation()
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
