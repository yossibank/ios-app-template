import Foundation
import ScreenCore
import Shared
@testable import SharedCore
import Testing

struct ProductBridgeTests {
    @Test("一覧の行が id・商品名・サムネイルの URL・ブランド・価格になる")
    func entriesBecomeProducts() {
        let entry = entry(id: 7, title: "Red Lipstick", brand: "Chic Cosmetics")
        let thumbnail = URL(string: "https://img.example/7.webp")

        let product = Product(entry)

        #expect(product.id == 7)
        #expect(product.title == "Red Lipstick")
        #expect(product.thumbnail == thumbnail)
        #expect(product.brand == "Chic Cosmetics")
        #expect(product.price == 12.99)
    }

    @Test("ブランドの無い商品はブランドが nil になる")
    func entriesWithoutABrandHaveNoBrand() {
        let entry = entry(id: 16, title: "Apple")
        let product = Product(entry)
        #expect(product.brand == nil)
    }

    @Test("失敗の種類が共通の文言になる")
    func failuresBecomeTheSharedMessages() {
        let offline = FetchFailure(ApiFailureOffline.shared)
        let timeout = FetchFailure(ApiFailureTimeout.shared)
        let unreadable = FetchFailure(ApiFailureUnreadable.shared)
        let unauthorized = FetchFailure(ApiFailureUnauthorized.shared)
        let server = serverFailure(503)

        #expect(offline == .offline)
        #expect(timeout == .timeout)
        #expect(unreadable == .unreadable)
        #expect(unauthorized == .unauthorized)
        #expect(server.message.contains("503"))
    }

    @Test("再試行できるかは共通コアの判断をそのまま使う")
    func retryabilityComesFromTheSharedCore() {
        let offline = FetchFailure(ApiFailureOffline.shared)
        let timeout = FetchFailure(ApiFailureTimeout.shared)
        let unavailable = serverFailure(503)
        let tooManyRequests = serverFailure(429)
        let notFound = serverFailure(404)
        let unreadable = FetchFailure(ApiFailureUnreadable.shared)
        let unauthorized = FetchFailure(ApiFailureUnauthorized.shared)

        #expect(offline.canRetry)
        #expect(timeout.canRetry)
        #expect(unavailable.canRetry)
        #expect(tooManyRequests.canRetry)
        #expect(!notFound.canRetry)
        #expect(!unreadable.canRetry)
        #expect(!unauthorized.canRetry)
    }

    @Test("読み込めたページが snapshot になる")
    func loadedResultsBecomeASnapshot() {
        let entries = [entry(id: 1, title: "Powder Canister")]

        let result = CatalogResultLoaded(
            entries: entries,
            hasMore: true,
            total: 194
        )

        let page = ProductListPage(result)

        guard case let .loaded(snapshot) = page else {
            Issue.record("読み込めたページになっていない")
            return
        }

        #expect(snapshot.products.map(\.id) == [1])
        #expect(snapshot.hasMore)
        #expect(snapshot.total == 194)
    }

    @Test("一部だけ失敗したページは理由を連れてくる")
    func degradedResultsCarryTheirFailure() {
        let entries = [entry(id: 1, title: "Powder Canister")]

        let result = CatalogResultDegraded(
            entries: entries,
            hasMore: true,
            total: 194,
            failure: ApiFailureOffline.shared
        )

        let page = ProductListPage(result)

        guard case let .degraded(snapshot, failure) = page else {
            Issue.record("一部だけ失敗したページになっていない")
            return
        }

        #expect(snapshot.products.count == 1)
        #expect(failure == .offline)
    }

    @Test("全部失敗したページは失敗になる")
    func failedResultsBecomeAFailure() {
        let result = CatalogResultFailed(failure: ApiFailureTimeout.shared)
        let page = ProductListPage(result)
        #expect(page == .failed(.timeout))
    }

    @Test("捨てられた結果はそのまま捨てられた結果になる")
    func staleResultsStayStale() {
        let page = ProductListPage(CatalogResultStale.shared)
        #expect(page == .stale)
    }
}

private extension ProductBridgeTests {
    func entry(
        id: Int32,
        title: String,
        brand: String? = nil
    ) -> CatalogEntry {
        CatalogEntry(
            id: id,
            title: title,
            thumbnailUrl: "https://img.example/\(id).webp",
            brand: brand,
            price: 12.99
        )
    }

    func serverFailure(_ statusCode: Int32) -> FetchFailure {
        let failure = ApiFailureServer(statusCode: statusCode)
        return FetchFailure(failure)
    }
}
