import ScreenCore
import SharedCore
import SwiftUI

struct HomeContent: View {
    private static let prefetchDistance = 8

    @Bindable var viewState: HomeViewModel.State

    let pokemon: [Pokemon]
    let actions: ScreenActions

    private var filtered: [Pokemon] {
        pokemon.filtered(query: viewState.query)
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
                PokemonListToolbar(
                    shown: items.count,
                    loaded: pokemon.count,
                    total: viewState.total,
                    filtering: isFiltering
                )

                PokemonGrid {
                    ForEach(items) { item in
                        PokemonCard(pokemon: item)
                            .onAppear {
                                guard
                                    !isFiltering,
                                    viewState.notice == nil,
                                    prefetch.contains(item.id)
                                else {
                                    return
                                }

                                actions.request(.loadMore)
                            }
                    }
                }

                if actions.isRunning(.loadMore) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PokemonMetrics.contentInset)
                }

                if let notice = viewState.notice {
                    Banner(text: notice.message, tint: .red, actionTitle: .homeReload) {
                        actions.request(notice.canRetry ? .loadMore : .reload)
                    }
                }
            }
            .pokemonContentInsets()
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
                actions.request(.reload)
            }
        }
    }
}
