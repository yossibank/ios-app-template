import ScreenCore

public struct ProductListSnapshot: Hashable, Sendable {
    public let products: [Product]
    public let hasMore: Bool
    public let total: Int

    public init(
        products: [Product],
        hasMore: Bool,
        total: Int
    ) {
        self.products = products
        self.hasMore = hasMore
        self.total = total
    }
}

public enum ProductListPage: Hashable, Sendable {
    case loaded(ProductListSnapshot)
    case degraded(ProductListSnapshot, FetchFailure)
    case failed(FetchFailure)
    case stale
}
