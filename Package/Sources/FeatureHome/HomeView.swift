import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>

    public var body: some View {
        ScreenView(source) { viewState, pokemon, actions in
            HomeContent(
                viewState: viewState,
                pokemon: pokemon,
                actions: actions
            )
        } empty: { actions in
            ContentUnavailableView {
                Label(HomeStrings.emptyTitle, systemImage: "tray")
            } description: {
                Text(HomeStrings.emptyDescription)
            } actions: {
                Button(HomeStrings.reload) {
                    actions.request(.reload)
                }
            }
        }
        .navigationTitle(HomeStrings.title)
        .environment(\.screenStyle, .standard.showingWhileLoading { PokemonSkeletonGrid() })
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private struct HomeContent: View {
    private static let prefetchDistance = 8

    @Bindable var viewState: HomeViewModel.State

    let pokemon: [Pokemon]
    let actions: ScreenActions

    private var filtered: [Pokemon] {
        pokemon.filtered(query: viewState.query, sort: viewState.sort)
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
                    filtering: isFiltering,
                    sort: $viewState.sort
                )

                PokemonGrid {
                    ForEach(items) { item in
                        PokemonCard(pokemon: item)
                            .onAppear {
                                guard !isFiltering, viewState.notice == nil, prefetch.contains(item.id) else {
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
                    Banner(text: notice.message, tint: .red, actionTitle: HomeStrings.reload) {
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
            prompt: HomeStrings.searchPrompt
        )
        .toolbar {
            Button(HomeStrings.reload, systemImage: "arrow.clockwise") {
                actions.request(.reload)
            }
        }
    }
}
