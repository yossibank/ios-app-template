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
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    let pokemon: [PokemonSummary]
    let actions: ScreenActions

    private static let prefetchDistance = 3

    private var filtered: [PokemonSummary] {
        guard !viewState.query.isEmpty else {
            return pokemon
        }

        return pokemon.filter {
            $0.name.localizedStandardContains(viewState.query)
        }
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(items.suffix(Self.prefetchDistance).map(\.url))

        List {
            ForEach(items, id: \.url) { item in
                Text(item.name)
                    .onAppear {
                        guard viewState.query.isEmpty, prefetch.contains(item.url) else {
                            return
                        }

                        actions.loadMore()
                    }
            }

            if actions.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
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
                actions.reload()
            }
        }
    }
}

#Preview("一覧") {
    HomeView(
        source: .snapshot(
            .loaded([
                PokemonSummary(name: "bulbasaur", url: "1"),
                PokemonSummary(name: "ivysaur", url: "2"),
                PokemonSummary(name: "venusaur", url: "3")
            ])
        )
    )
}

#Preview("続きを読み込み中") {
    HomeView(
        source: .snapshot(
            .loadingMore([
                PokemonSummary(name: "bulbasaur", url: "1"),
                PokemonSummary(name: "ivysaur", url: "2")
            ])
        )
    )
}

#Preview("空") {
    HomeView(
        source: .snapshot(
            .loaded([])
        )
    )
}
