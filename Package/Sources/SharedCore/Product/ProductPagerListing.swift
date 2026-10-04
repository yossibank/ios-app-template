import ScreenCore
import Shared

public final class ProductPagerListing: ProductListing, @unchecked Sendable {
    private let pager = CatalogPager()

    public var pageSize: Int {
        Int(pager.pageSize)
    }

    public init() {}

    public func reload() async -> ProductListPage {
        do {
            return try await ProductListPage(pager.reload())
        } catch is CancellationError {
            return .stale
        } catch {
            return .failed(.unexpected(canRetry: true))
        }
    }

    public func loadNext() async -> ProductListPage {
        do {
            return try await ProductListPage(pager.loadNext())
        } catch is CancellationError {
            return .stale
        } catch {
            return .failed(.unexpected(canRetry: true))
        }
    }
}
