import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel {
    let viewState = State()
    let fetchState = FetchState<ProductList>()
    let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension HomeViewModel {
    @Observable
    final class State: ScreenViewState {
        var query = ""
    }

    struct Dependency {
        var listing: any ProductListing = ProductPagerListing()
    }

    convenience init() {
        self.init(dependency: .init())
    }
}

private extension HomeViewModel {
    var pageSize: Int {
        dependency.listing.pageSize
    }

    func page(
        _ list: ProductList,
        hasMore: Bool
    ) -> FetchMore<ProductList> {
        hasMore ? .more(list) : .last(list)
    }

    func notice(_ failure: FetchFailure) throws(FetchFailure) -> FetchFailure {
        if failure.endsSession {
            throw failure
        }

        return failure
    }
}

extension HomeViewModel: ScreenViewModel {
    func fetch() async throws(FetchFailure) -> ProductList {
        switch await dependency.listing.reload() {
        case let .loaded(snapshot):
            return ProductList(snapshot, pageSize: pageSize)

        case let .degraded(snapshot, failure):
            let reported = try notice(failure)
            return ProductList(snapshot, pageSize: pageSize, notice: reported)

        case let .failed(failure):
            throw failure

        case .stale:
            return ProductList(
                products: [],
                total: 0,
                pageSize: pageSize
            )
        }
    }

    func fetchMore(
        after current: ProductList
    ) async throws(FetchFailure) -> FetchMore<ProductList> {
        switch await dependency.listing.loadNext() {
        case let .loaded(snapshot):
            let list = ProductList(snapshot, pageSize: pageSize)
            return page(list, hasMore: snapshot.hasMore)

        case let .degraded(snapshot, failure):
            let reported = try notice(failure)
            let list = ProductList(snapshot, pageSize: pageSize, notice: reported)
            return page(list, hasMore: snapshot.hasMore)

        case let .failed(failure):
            let reported = try notice(failure)

            let list = ProductList(
                products: current.products,
                total: current.total,
                pageSize: pageSize,
                notice: reported
            )

            return .more(list)

        case .stale:
            return .unchanged
        }
    }
}
