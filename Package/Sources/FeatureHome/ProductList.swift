import ScreenCore
import SharedCore

struct ProductList {
    var products: [Product]
    var total: Int
    var pageSize: Int
    var notice: FetchFailure?
}

extension ProductList {
    init(
        _ snapshot: ProductListSnapshot,
        pageSize: Int,
        notice: FetchFailure? = nil
    ) {
        self.init(
            products: snapshot.products,
            total: snapshot.total,
            pageSize: pageSize,
            notice: notice
        )
    }
}
