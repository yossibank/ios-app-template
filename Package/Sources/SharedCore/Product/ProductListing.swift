public protocol ProductListing: Sendable {
    func reload() async -> ProductListPage
    func loadNext() async -> ProductListPage
}
