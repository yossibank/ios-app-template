import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>

    public var body: some View {
        ScreenView(source, isEmpty: \.pokemon.isEmpty) { viewState, list, actions in
            HomeContent(
                viewState: viewState,
                list: list,
                actions: actions
            )
        } empty: { actions in
            empty(actions)
        } loading: {
            skeleton
        }
        .navigationTitle(.homeTitle)
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private extension HomeView {
    func empty(_ actions: ScreenActions) -> some View {
        ContentUnavailableView {
            Label(.homeEmptyTitle, systemImage: "tray")
        } description: {
            Text(.homeEmptyDescription)
        } actions: {
            Button(.homeReload) {
                actions.reload()
            }
        }
    }

    var skeleton: some View {
        ScrollView {
            PokemonGrid {
                ForEach(0..<8, id: \.self) { _ in
                    PokemonCard(pokemon: .placeholder)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .skeleton()
        }
        .scrollDisabled(true)
    }
}

enum Preview {
    static var list: PokemonList {
        PokemonList(pokemon: pokemon, total: 1351)
    }

    static var listWithError: PokemonList {
        PokemonList(pokemon: pokemon, total: 1351, notice: .offline)
    }

    static var pokemon: [Pokemon] {
        [
            Pokemon(id: 1, name: "bulbasaur", artwork: nil),
            Pokemon(id: 4, name: "charmander", artwork: nil),
            Pokemon(id: 7, name: "squirtle", artwork: nil),
            Pokemon(id: 10, name: "caterpie", artwork: nil),
            Pokemon(id: 25, name: "pikachu", artwork: nil),
            Pokemon(id: 149, name: "dragonite", artwork: nil)
        ]
    }
}

#Preview("一覧") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.list)))
    }
}

#Preview("読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loading))
    }
}

#Preview("続きを読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.list), loadingMore: true))
    }
}

#Preview("バナー付き") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.listWithError)))
    }
}

#Preview("失敗") {
    NavigationStack {
        HomeView(source: .snapshot(.failed(.offline)))
    }
}

#Preview("空") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(PokemonList(pokemon: [], total: 0))))
    }
}
