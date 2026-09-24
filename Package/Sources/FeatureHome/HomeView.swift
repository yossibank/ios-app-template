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
    @Bindable var viewState: HomeViewModel.State

    @Namespace private var cardNamespace

    let pokemon: [Pokemon]
    let actions: ScreenActions

    private var filtered: [Pokemon] {
        pokemon.filtered(
            query: viewState.query,
            type: viewState.selectedType,
            sort: viewState.sort
        )
    }

    private var isFiltering: Bool {
        !viewState.query.isEmpty || viewState.selectedType != nil
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(PokemonList.prefetchDistance)
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

                PokemonFilterBar(types: pokemon.availableTypes, selected: $viewState.selectedType)

                if viewState.incompleteCount > 0 {
                    Banner(
                        text: HomeStrings.incomplete(viewState.incompleteCount),
                        actionTitle: HomeStrings.retryDetails,
                        isBusy: actions.isRunning(.repair)
                    ) {
                        actions.request(.repair)
                    }
                }

                PokemonGrid {
                    ForEach(items) { item in
                        Button {
                            viewState.route = .detail(item)
                        } label: {
                            PokemonCard(pokemon: item)
                        }
                        .buttonStyle(.card)
                        .matchedTransitionSource(id: item.id, in: cardNamespace)
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
                    Banner(text: notice.failure.message, tint: .red, actionTitle: HomeStrings.reload) {
                        actions.request(notice.failure.canRetry ? notice.retry : .reload)
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
                PokemonNoMatch(query: viewState.query, selectedType: viewState.selectedType)
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
        .navigationDestination(item: $viewState.route) { route in
            PokemonDetailView(pokemon: route.pokemon)
                .navigationTransition(.zoom(sourceID: route.pokemon.id, in: cardNamespace))
        }
    }
}
