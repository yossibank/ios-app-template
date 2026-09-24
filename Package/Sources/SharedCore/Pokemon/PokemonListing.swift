import Shared

public protocol PokemonListing: Sendable {
    func reload() async -> PokemonListPage
    func loadNext() async -> PokemonListPage
    func retryMissingDetails() async -> PokemonListPage
    func close()
}

public enum PokemonList {
    public static let prefetchDistance = Int(PokemonPager.companion.PREFETCH_DISTANCE)
}
