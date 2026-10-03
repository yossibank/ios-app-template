import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class HomeViewModel: ScreenViewModel {
    let viewState = State()
    let fetchState = FetchState<ProductList>()
    let dependency: Dependency

    convenience init() {
        self.init(dependency: .init())
    }

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

private extension HomeViewModel {
    func page(_ list: ProductList, hasMore: Bool) -> FetchMore<ProductList> {
        hasMore ? .more(list) : .last(list)
    }

    func notice(_ failure: FetchFailure) throws(FetchFailure) -> FetchFailure {
        if failure.endsSession {
            throw failure
        }

        return failure
    }
}

extension HomeViewModel {
    func fetch() async throws(FetchFailure) -> ProductList {
        switch await dependency.listing.reload() {
        case let .loaded(snapshot):
            ProductList(snapshot)

        case let .degraded(snapshot, failure):
            try ProductList(snapshot, notice: notice(failure))

        case let .failed(failure):
            throw failure

        case .stale:
            ProductList(products: [], total: 0)
        }
    }

    func fetchMore(
        after current: ProductList
    ) async throws(FetchFailure) -> FetchMore<ProductList> {
        switch await dependency.listing.loadNext() {
        case let .loaded(snapshot):
            page(
                ProductList(snapshot),
                hasMore: snapshot.hasMore
            )

        case let .degraded(snapshot, failure):
            try page(
                ProductList(snapshot, notice: notice(failure)),
                hasMore: snapshot.hasMore
            )

        case let .failed(failure):
            try .more(
                ProductList(
                    products: current.products,
                    total: current.total,
                    notice: notice(failure)
                )
            )

        case .stale:
            .unchanged
        }
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
}
