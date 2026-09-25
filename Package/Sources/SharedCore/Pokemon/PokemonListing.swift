public protocol PokemonListing: Sendable {
    func reload() async -> PokemonListPage
    func loadNext() async -> PokemonListPage
    func close()
}
