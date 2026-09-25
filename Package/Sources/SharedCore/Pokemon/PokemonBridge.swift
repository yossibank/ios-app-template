import Foundation
import ScreenCore
import Shared

extension Pokemon {
    init(_ entry: PokemonEntry) {
        self.init(
            id: Int(entry.id),
            name: entry.name,
            artwork: URL(string: entry.imageUrl)
        )
    }
}

extension FetchFailure {
    init(_ failure: any ApiFailure) {
        self = switch onEnum(of: failure) {
        case .offline: .offline
        case .timeout: .timeout
        case let .server(server): .server(statusCode: Int(server.statusCode), canRetry: server.canRetry)
        case .unreadable: .unreadable
        case .closed: .unexpected(canRetry: false)
        }
    }
}

extension PokemonListSnapshot {
    init(pokemon: [PokemonEntry], hasMore: Bool, total: Int32) {
        self.init(
            pokemon: pokemon.map(Pokemon.init),
            hasMore: hasMore,
            total: Int(total)
        )
    }
}

extension PokemonListPage {
    init(_ result: PokemonListResult) {
        switch onEnum(of: result) {
        case let .loaded(loaded):
            let snapshot = PokemonListSnapshot(
                pokemon: loaded.pokemon,
                hasMore: loaded.hasMore,
                total: loaded.total
            )

            self = if let failure = loaded.failure {
                .degraded(snapshot, FetchFailure(failure))
            } else {
                .loaded(snapshot)
            }

        case let .failed(failed):
            self = .failed(FetchFailure(failed.failure))

        case .stale:
            self = .stale
        }
    }
}
