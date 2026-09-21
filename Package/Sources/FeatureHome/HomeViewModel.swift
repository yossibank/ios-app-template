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

        switch onEnum(of: result) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil)
            return loaded.pokemon

        case let .failed(failed):
            guard !failed.pokemon.isEmpty else {
                throw failed.failure.asFetchFailure
            }

            record(incomplete: failed.incompleteCount, notice: failed.failure.asFetchFailure)
            return failed.pokemon
        }
    }

    func fetchMore() async throws(FetchFailure) -> FetchMore<[PokemonEntry]>? {
        let result = try await nextPage()

        switch onEnum(of: result) {
        case let .loaded(loaded):
            record(incomplete: loaded.incompleteCount, notice: nil)
            return loaded.hasMore ? .more(loaded.pokemon) : .last(loaded.pokemon)

        case let .failed(failed):
            record(incomplete: failed.incompleteCount, notice: failed.failure.asFetchFailure)
            return .last(failed.pokemon)
        }
    }

    func close() {
        dependency.paging.close()
    }

    private func record(incomplete: Int32, notice: FetchFailure?) {
        viewState.incompleteCount = Int(incomplete)
        viewState.notice = notice
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
        var incompleteCount = 0
        var notice: FetchFailure?
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
