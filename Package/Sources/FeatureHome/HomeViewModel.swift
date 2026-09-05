import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
@Requires("Observable")
public final class HomeViewModel: ScreenViewModel {
    public struct Dependency {
        public var api: PokemonApi

        public init(api: PokemonApi = PokemonApi()) {
            self.api = api
        }
    }

    public let screen = ScreenState<[PokemonSummary]>()
    public let dependency: Dependency

    public init(dependency: Dependency = .init()) {
        self.dependency = dependency
    }

    public func fetch() async throws -> [PokemonSummary] {
        let result = try await dependency.api.fetchPage(limit: 20, offset: 0)

        switch onEnum(of: result) {
        case let .loaded(loaded):
            return loaded.pokemon

        case let .failed(failed):
            throw ScreenFailure(failed.message)
        }
    }
}
