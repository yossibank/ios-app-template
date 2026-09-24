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

    @State private var opened: PokemonEntry?

    @Namespace private var cardNamespace

    let pokemon: [PokemonEntry]
    let actions: ScreenActions

    private var availableTypes: [PokemonTypeKind] {
        var seen: [PokemonTypeKind] = []

        for entry in pokemon {
            guard let detail = entry.loadedDetail else {
                continue
            }

            for type in detail.types where !seen.contains(type) {
                seen.append(type)
            }
        }

        return seen
    }

    private var filtered: [PokemonEntry] {
        pokemon
            .filter { entry in
                let matchesName = viewState.query.isEmpty
                    || entry.name.localizedStandardContains(viewState.query)

                return matchesName && entry.matches(viewState.selectedType)
            }
            .sorted(by: viewState.sort.areInIncreasingOrder)
    }

    private var isFiltering: Bool {
        !viewState.query.isEmpty || viewState.selectedType != nil
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(Int(PokemonPager.companion.PREFETCH_DISTANCE))
                .map(\.id)
        )

        ScrollView {
            LazyVStack(spacing: 12) {
                PokemonListToolbar(
                    shown: items.count,
                    loaded: pokemon.count,
                    total: viewState.total,
                    filtering: isFiltering,
                    sort: $viewState.sort
                )

                PokemonFilterBar(types: availableTypes, selected: $viewState.selectedType)

                if viewState.incompleteCount > 0 {
                    Banner(
                        text: HomeStrings.incomplete(viewState.incompleteCount),
                        action: HomeStrings.retryDetails,
                        busy: actions.isRunning(.refill)
                    ) {
                        actions.request(.refill)
                    }
                }

                LazyVGrid(columns: PokemonMetrics.gridColumns, spacing: 10) {
                    ForEach(items, id: \.id) { item in
                        Button {
                            opened = item
                        } label: {
                            PokemonCard(pokemon: item)
                        }
                        .buttonStyle(CardButtonStyle())
                        .matchedTransitionSource(id: item.id, in: cardNamespace)
                        .onAppear {
                            guard !isFiltering, prefetch.contains(item.id) else {
                                return
                            }

                            actions.request(.loadMore)
                        }
                    }
                }

                if actions.isRunning(.loadMore) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                if let notice = viewState.notice {
                    Banner(text: notice.message, color: .red, action: HomeStrings.reload) {
                        actions.request(.reload)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
        .navigationDestination(item: $opened) { entry in
            PokemonDetailView(pokemon: entry)
                .navigationTransition(.zoom(sourceID: entry.id, in: cardNamespace))
        }
    }
}
