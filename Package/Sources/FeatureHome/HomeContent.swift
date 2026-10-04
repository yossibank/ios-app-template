import ScreenCore
import SharedCore
import SwiftUI

struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    @State private var isRefreshing = false
    @State private var position = ScrollPosition(edge: .top)

    let list: ProductList
    let actions: ScreenActions

    var body: some View {
        let items = list.products.filtered(query: viewState.query)

        VStack(alignment: .leading, spacing: 0) {
            SearchField(query: $viewState.query)
                .padding(.horizontal, 20)

            if isFiltering {
                summary(matched: items.count)
            }

            ScrollView {
                if isFiltering {
                    results(items)
                } else {
                    catalog
                }
            }
            .scrollPosition($position)
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
                await refresh()
            }
            .overlay {
                if isFiltering, items.isEmpty {
                    noMatch
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
        }
    }
}

private extension HomeContent {
    var catalog: some View {
        let prefetch = Set(list.products.suffix(8).map(\.id))

        return LazyVStack(alignment: .leading, spacing: 26) {
            ForEach(list.chapters) { chapter in
                ChapterHeader(numeral: chapter.numeral, first: chapter.first, last: chapter.last)

                ForEach(chapter.spreads) { spread in
                    ProductLead(product: spread.lead)
                        .onAppear {
                            loadMore(at: spread.lead, prefetch: prefetch)
                        }

                    if !spread.pair.isEmpty {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(spread.pair) { product in
                                ProductTile(product: product)
                                    .onAppear {
                                        loadMore(at: product, prefetch: prefetch)
                                    }
                            }

                            if spread.pair.count == 1 {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }

            if isLoadingMore {
                if let next = list.nextChapter {
                    ChapterHeader(
                        numeral: next.numeral,
                        first: next.first,
                        last: next.last,
                        isLoading: true
                    )
                }

                LeadSkeleton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    func results(_ items: [Product]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(items) { product in
                ProductRow(product: product, query: viewState.query)
            }
        }
        .padding(.horizontal, 20)
    }

    func summary(matched: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(.homeProgressFilteredCount(matched))
                .font(.atelierMincho(15, relativeTo: .subheadline, bold: true))

            Text(.homeProgressFilteredDetail(list.total, list.products.count))
                .font(.caption)
                .foregroundStyle(Color.atelierMuted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
    }

    var noMatch: some View {
        VStack(spacing: 16) {
            Text(0, format: .number)
                .font(.atelierSerif(64, relativeTo: .largeTitle, italic: true))
                .foregroundStyle(Color.atelierLine)
                .accessibilityHidden(true)

            Text(.homeNoMatchTitle(viewState.query))
                .font(.atelierMincho(18, relativeTo: .headline, bold: true))
                .multilineTextAlignment(.center)

            Text(.homeNoMatchDescription)
                .font(.footnote)
                .foregroundStyle(Color.atelierMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 36)
    }

    var bottomBar: some View {
        VStack(spacing: 8) {
            if let notice = list.notice {
                BannerView(
                    text: String(localized: .homeLoadMoreFailed(notice.message)),
                    accessory: actions.isLoadingMore || isRefreshing
                        ? .progress
                        : .retry { retry(after: notice) }
                )
                .padding(.horizontal, 16)
            }

            if !isFiltering {
                CatalogFooter(loaded: list.products.count, total: list.total)
                    .onTapGesture {
                        withAnimation {
                            position.scrollTo(edge: .top)
                        }
                    }
            }
        }
    }
}

private extension HomeContent {
    var isFiltering: Bool {
        !viewState.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isLoadingMore: Bool {
        actions.isLoadingMore && list.notice == nil
    }

    func loadMore(at item: Product, prefetch: Set<Product.ID>) {
        guard
            !isFiltering,
            list.notice == nil,
            prefetch.contains(item.id)
        else {
            return
        }

        actions.loadMore()
    }

    func refresh() async {
        isRefreshing = true

        defer {
            isRefreshing = false
        }

        await actions.refresh()
    }

    func retry(after notice: FetchFailure) {
        if notice.canRetry {
            actions.loadMore()
        } else {
            Task {
                await refresh()
            }
        }
    }
}

struct LeadSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .aspectRatio(16 / 11, contentMode: .fit)

            Rectangle()
                .frame(width: 96, height: 10)

            HStack {
                Rectangle()
                    .frame(width: 180, height: 16)

                Spacer()

                Rectangle()
                    .frame(width: 60, height: 18)
            }
        }
        .foregroundStyle(Color.atelierSkeleton)
        .skeleton()
        .accessibilityHidden(true)
    }
}

struct TileSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)

            Rectangle()
                .frame(width: 110, height: 12)

            Rectangle()
                .frame(width: 50, height: 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.atelierSkeleton)
        .skeleton()
        .accessibilityHidden(true)
    }
}
