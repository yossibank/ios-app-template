import ScreenCore
import SharedCore
import SwiftUI

struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    @State private var isRefreshing = false
    @State private var position = ScrollPosition(edge: .top)

    let list: PokemonList
    let actions: ScreenActions

    var body: some View {
        let items = list.pokemon.filtered(query: viewState.query)

        ScrollView {
            LazyVStack(spacing: 16) {
                grid(items)

                if let notice = list.notice {
                    BannerView(
                        text: notice.message,
                        style: .failure,
                        accessory: actions.isLoadingMore || isRefreshing
                            ? .progress
                            : .retry { retry(after: notice) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollPosition($position)
        .safeAreaInset(edge: .bottom) {
            if !items.isEmpty {
                gauge(matched: isFiltering ? items.count : nil)
            }
        }
        .refreshable {
            await refresh()
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView.search(text: viewState.query)
            }
        }
        .searchable(
            text: $viewState.query,
            prompt: .homeSearchPrompt
        )
    }
}

private extension HomeContent {
    func grid(_ items: [Pokemon]) -> some View {
        let prefetch = Set(items.suffix(8).map(\.id))

        return PokemonGrid {
            ForEach(items) { item in
                PokemonCard(pokemon: item)
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.94)
                            .opacity(phase.isIdentity ? 1 : 0.6)
                    }
                    .onAppear {
                        loadMore(at: item, prefetch: prefetch)
                    }
            }

            if isLoadingMore {
                ForEach(0..<2, id: \.self) { _ in
                    PokemonCard(pokemon: .placeholder)
                        .skeleton()
                }
            }
        }
    }

    func gauge(matched: Int?) -> some View {
        PokemonListGauge(
            loaded: list.pokemon.count,
            total: list.total,
            matched: matched
        )
        .onTapGesture {
            withAnimation {
                position.scrollTo(edge: .top)
            }
        }
        .padding(.bottom, 8)
    }
}

private extension HomeContent {
    var isFiltering: Bool {
        !viewState.query.isEmpty
    }

    var isLoadingMore: Bool {
        actions.isLoadingMore && list.notice == nil
    }

    func loadMore(at item: Pokemon, prefetch: Set<Pokemon.ID>) {
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
