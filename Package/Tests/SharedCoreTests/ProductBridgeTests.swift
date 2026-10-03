import Foundation
import ScreenCore
import Shared
@testable import SharedCore
import Testing

struct ProductBridgeTests {
    @Test("一覧の行が id・商品名・サムネイルの URL になる")
    func entriesBecomeProducts() {
        let product = Product(entry(id: 7, title: "Red Lipstick"))

        #expect(product.id == 7)
        #expect(product.title == "Red Lipstick")
        #expect(product.thumbnail == URL(string: "https://img.example/7.webp"))
    }

    @Test("失敗の種類が共通の文言になる")
    func failuresBecomeTheSharedMessages() {
        #expect(FetchFailure(ApiFailureOffline.shared) == .offline)
        #expect(FetchFailure(ApiFailureTimeout.shared) == .timeout)
        #expect(FetchFailure(ApiFailureUnreadable.shared) == .unreadable)
        #expect(FetchFailure(ApiFailureUnauthorized.shared) == .unauthorized)
        #expect(FetchFailure(ApiFailureServer(statusCode: 503)).message.contains("503"))
    }

    @Test("再試行できるかは共通コアの判断をそのまま使う")
    func retryabilityComesFromTheSharedCore() {
        #expect(FetchFailure(ApiFailureOffline.shared).canRetry)
        #expect(FetchFailure(ApiFailureTimeout.shared).canRetry)
        #expect(FetchFailure(ApiFailureServer(statusCode: 503)).canRetry)
        #expect(FetchFailure(ApiFailureServer(statusCode: 429)).canRetry)
        #expect(!FetchFailure(ApiFailureServer(statusCode: 404)).canRetry)
        #expect(!FetchFailure(ApiFailureUnreadable.shared).canRetry)
        #expect(!FetchFailure(ApiFailureUnauthorized.shared).canRetry)
    }

    @Test("読み込めたページが snapshot になる")
    func loadedResultsBecomeASnapshot() {
        let page = ProductListPage(
            ProductListResultLoaded(
                products: [entry(id: 1, title: "Powder Canister")],
                hasMore: true,
                total: 194
            )
        )

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
        let page = ProductListPage(
            ProductListResultDegraded(
                products: [entry(id: 1, title: "Powder Canister")],
                hasMore: true,
                total: 194,
                failure: ApiFailureOffline.shared
            )
        )

        guard case let .degraded(snapshot, failure) = page else {
            Issue.record("一部だけ失敗したページになっていない")
            return
        }

        #expect(snapshot.products.count == 1)
        #expect(failure == .offline)
    }

    @Test("全部失敗したページは失敗になる")
    func failedResultsBecomeAFailure() {
        let page = ProductListPage(ProductListResultFailed(failure: ApiFailureTimeout.shared))

        #expect(page == .failed(.timeout))
    }

    @Test("捨てられた結果はそのまま捨てられた結果になる")
    func staleResultsStayStale() {
        #expect(ProductListPage(ProductListResultStale.shared) == .stale)
    }

    private func entry(id: Int32, title: String) -> ProductEntry {
        ProductEntry(id: id, title: title, thumbnailUrl: "https://img.example/\(id).webp")
    }
}
