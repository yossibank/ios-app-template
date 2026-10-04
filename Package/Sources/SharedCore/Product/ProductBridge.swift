import Foundation
import ScreenCore
import Shared

extension Product {
    init(_ entry: CatalogEntry) {
        self.init(
            id: Int(entry.id),
            title: entry.title,
            thumbnail: URL(string: entry.thumbnailUrl),
            brand: entry.brand,
            price: entry.price
        )
    }
}

extension ProductListSnapshot {
    init(products: [CatalogEntry], hasMore: Bool, total: Int32) {
        self.init(
            products: products.map(Product.init),
            hasMore: hasMore,
            total: Int(total)
        )
    }
}

extension ProductListPage {
    init(_ result: CatalogResult) {
        switch onEnum(of: result) {
        case let .loaded(loaded):
            self = .loaded(
                ProductListSnapshot(
                    products: loaded.entries,
                    hasMore: loaded.hasMore,
                    total: loaded.total
                )
            )

        case let .degraded(degraded):
            self = .degraded(
                ProductListSnapshot(
                    products: degraded.entries,
                    hasMore: degraded.hasMore,
                    total: degraded.total
                ),
                FetchFailure(degraded.failure)
            )

        case let .failed(failed):
            self = .failed(FetchFailure(failed.failure))

        case .stale:
            self = .stale
        }
    }
}
