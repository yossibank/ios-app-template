import Foundation
import ScreenCore
import Shared

extension Product {
    init(_ entry: ProductEntry) {
        self.init(
            id: Int(entry.id),
            title: entry.title,
            thumbnail: URL(string: entry.thumbnailUrl)
        )
    }
}

extension ProductListSnapshot {
    init(products: [ProductEntry], hasMore: Bool, total: Int32) {
        self.init(
            products: products.map(Product.init),
            hasMore: hasMore,
            total: Int(total)
        )
    }
}

extension ProductListPage {
    init(_ result: ProductListResult) {
        switch onEnum(of: result) {
        case let .loaded(loaded):
            self = .loaded(
                ProductListSnapshot(
                    products: loaded.products,
                    hasMore: loaded.hasMore,
                    total: loaded.total
                )
            )

        case let .degraded(degraded):
            self = .degraded(
                ProductListSnapshot(
                    products: degraded.products,
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
