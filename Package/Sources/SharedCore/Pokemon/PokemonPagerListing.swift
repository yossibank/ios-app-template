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
            return .failed(.interrupted)
        }

        return await loadNext()
    }

    public func loadNext() async -> PokemonListPage {
        await page { try await pager.loadNext() }
    }

    public func retryMissingDetails() async -> PokemonListPage {
        await page { try await pager.retryMissingDetails() }
    }

    public func close() {
        pager.close()
    }

    private func page(_ work: () async throws -> PokemonListResult) async -> PokemonListPage {
        do {
            return try await PokemonListPage(work())
        } catch is CancellationError {
            return .stale
        } catch {
            return .failed(.interrupted)
        }
    }
}
