public protocol ProductListing: Sendable {
    var pageSize: Int { get }
    func reload() async -> ProductListPage
    func loadNext() async -> ProductListPage
}
