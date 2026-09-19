import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>

    public var body: some View {
        ScreenView(source) { viewState, pokemon in
            HomeContent(viewState: viewState, pokemon: pokemon)
        }
        .navigationTitle("ポケモン")
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private struct HomeContent: View {
    @Environment(\.screenReload) private var reload
    @Environment(\.screenLoadMore) private var loadMore
    @Environment(\.screenIsLoadingMore) private var isLoadingMore

    @Bindable var viewState: HomeViewModel.State

    let pokemon: [PokemonSummary]

    private var filtered: [PokemonSummary] {
        guard !viewState.query.isEmpty else {
            return pokemon
        }

        return pokemon.filter {
            $0.name.localizedStandardContains(viewState.query)
        }
    }

    var body: some View {
        List {
            ForEach(filtered, id: \.url) { item in
                Text(item.name)
                    .onAppear {
                        guard viewState.query.isEmpty, item.url == pokemon.last?.url else {
                            return
                        }

                        loadMore()
                    }
            }

            if isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .overlay {
            if pokemon.isEmpty {
                ContentUnavailableView {
                    Label("ポケモンがいません", systemImage: "tray")
                } description: {
                    Text("取得できましたが 1 件もありませんでした")
                } actions: {
                    Button("再取得") {
                        reload()
                    }
                }
            } else if filtered.isEmpty {
                ContentUnavailableView.search(text: viewState.query)
            }
        }
        .searchable(text: $viewState.query, prompt: "名前で絞り込む")
        .toolbar {
            Button("再取得", systemImage: "arrow.clockwise") {
                reload()
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

#Preview("空") {
    HomeView(source: .snapshot(.loaded([])))
}
