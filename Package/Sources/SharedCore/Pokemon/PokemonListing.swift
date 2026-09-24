public protocol PokemonListing: Sendable {
    func reload() async -> PokemonListPage
    func loadNext() async -> PokemonListPage
    func retryMissingDetails() async -> PokemonListPage
    func close()
}
