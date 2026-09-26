import ScreenCore
import SharedCore
import SwiftUI

struct HomeContent: View {
    private static let prefetchDistance = 8

    @Bindable var viewState: HomeViewModel.State

    let list: PokemonList
    let actions: ScreenActions

    private var filtered: [Pokemon] {
        list.pokemon.filtered(query: viewState.query)
    }

    private var isFiltering: Bool {
        !viewState.query.isEmpty
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(Self.prefetchDistance)
                .map(\.id)
        )

        ScrollView {
            LazyVStack(spacing: PokemonMetrics.contentInset) {
                PokemonGrid {
                    ForEach(items) { item in
                        PokemonCard(pokemon: item)
                            .onAppear {
                                guard
                                    !isFiltering,
                                    list.notice == nil,
                                    prefetch.contains(item.id)
                                else {
                                    return
                                }

                                actions.loadMore()
                            }
                    }
                }

                if actions.isLoadingMore, list.notice == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PokemonMetrics.contentInset)
                }

                if let notice = list.notice {
                    Banner(
                        text: notice.message,
                        tint: .red,
                        actionTitle: .homeReload,
                        isBusy: actions.isLoadingMore
                    ) {
                        if notice.canRetry {
                            actions.loadMore()
                        } else {
                            actions.reload()
                        }
                    }
                }
            }
            .pokemonContentInsets()
        }
        .safeAreaInset(edge: .bottom) {
            PokemonListToolbar(
                shown: items.count,
                loaded: list.pokemon.count,
                total: list.total,
                filtering: isFiltering
            )
            .padding(.bottom, PokemonMetrics.contentTopInset)
        }
        .refreshable {
            await actions.refresh()
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
        .toolbar {
            Button(.homeReload, systemImage: "arrow.clockwise") {
                actions.reload()
            }
        }
    }
}
