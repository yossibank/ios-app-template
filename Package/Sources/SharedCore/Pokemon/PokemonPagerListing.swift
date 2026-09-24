import ScreenCore
import Shared

public final class PokemonPagerListing: PokemonListing, @unchecked Sendable {
    private let pager = PokemonPager()

    public init() {}

    public func reload() async -> PokemonListPage {
        do {
            try await pager.reset()
        } catch is CancellationError {
            return .stale
        } catch {
            return .failed(.unexpected(canRetry: true))
        }

        return await loadNext()
    }

    public func loadNext() async -> PokemonListPage {
        do {
            return try await PokemonListPage(pager.loadNext())
        } catch is CancellationError {
            return .stale
        } catch {
            return .failed(.unexpected(canRetry: true))
        }
    }

    public func close() {
        pager.close()
    }
}
