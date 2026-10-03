import ScreenCore
import SharedCore

struct ProductList {
    var products: [Product]
    var total: Int
    var notice: FetchFailure?
}

extension ProductList {
    init(
        _ snapshot: ProductListSnapshot,
        notice: FetchFailure? = nil
    ) {
        self.init(
            products: snapshot.products,
            total: snapshot.total,
            notice: notice
        )
    }
}
