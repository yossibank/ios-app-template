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
                    actions.reload()
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

struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    @State private var opened: PokemonEntry?

    @Namespace private var cardNamespace

    let pokemon: [PokemonEntry]
    let actions: ScreenActions

    private var availableTypes: [PokemonTypeKind] {
        var seen: [PokemonTypeKind] = []

        for entry in pokemon {
            guard case let .loaded(detail) = onEnum(of: entry.detail) else {
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
                        busy: actions.isRefilling
                    ) {
                        actions.refill()
                    }
                }

                LazyVGrid(columns: gridColumns, spacing: 10) {
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

                            actions.loadMore()
                        }
                    }
                }

                if actions.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                if let notice = viewState.notice {
                    Banner(text: notice.message, color: .red) {
                        actions.reload()
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
                actions.reload()
            }
        }
        .navigationDestination(item: $opened) { entry in
            PokemonDetailView(pokemon: entry)
                .navigationTransition(.zoom(sourceID: entry.id, in: cardNamespace))
        }
    }
}

enum PreviewData {
    static var pokemon: [PokemonEntry] {
        [
            entry(id: 1, name: "bulbasaur", types: [.grass, .poison], stats: [45, 49, 49, 65, 65, 45]),
            entry(id: 4, name: "charmander", types: [.fire], stats: [39, 52, 43, 60, 50, 65]),
            entry(id: 7, name: "squirtle", types: [.water], stats: [44, 48, 65, 50, 64, 43]),
            entry(id: 10, name: "caterpie", types: [.bug], stats: [45, 30, 35, 20, 20, 45]),
            entry(id: 25, name: "pikachu", types: [.electric], stats: [35, 55, 40, 50, 50, 90]),
            entry(id: 149, name: "dragonite", types: [.dragon, .flying], stats: [91, 134, 95, 100, 100, 80])
        ]
    }

    static var degraded: PokemonEntry {
        PokemonEntry(
            id: 132,
            name: "ditto",
            detail: PokemonEntryDetailMissing(failure: PokemonFailureServer(statusCode: 500))
        )
    }

    private static func entry(
        id: Int32,
        name: String,
        types: [PokemonTypeKind],
        stats: [Int32]
    ) -> PokemonEntry {
        let kinds: [PokemonStatKind] = [
            .hp, .attack, .defense, .specialAttack, .specialDefense, .speed
        ]

        return PokemonEntry(
            id: id,
            name: name,
            detail: PokemonEntryDetailLoaded(
                spriteUrl: nil,
                artworkUrl: nil,
                types: types,
                baseStats: zip(kinds, stats).map { PokemonBaseStat(kind: $0, value: $1) }
            )
        )
    }
}

#Preview("一覧") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(PreviewData.pokemon)))
    }
}

#Preview("読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loading))
    }
}

#Preview("続きを読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loadingMore(PreviewData.pokemon)))
    }
}

#Preview("詳細を引けなかった行") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded([PreviewData.degraded] + PreviewData.pokemon)))
    }
}

#Preview("空") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded([])))
    }
}
