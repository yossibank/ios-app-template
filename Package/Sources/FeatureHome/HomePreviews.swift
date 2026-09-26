#if DEBUG
    import ScreenCore
    import SharedCore
    import SwiftUI

    private enum PreviewData {
        static var list: PokemonList {
            PokemonList(pokemon: pokemon, total: 1351)
        }

        static var degradedList: PokemonList {
            PokemonList(pokemon: pokemon, total: 1351, notice: .offline)
        }

        static var pokemon: [Pokemon] {
            [
                .fixture(id: 1, name: "bulbasaur"),
                .fixture(id: 4, name: "charmander"),
                .fixture(id: 7, name: "squirtle"),
                .fixture(id: 10, name: "caterpie"),
                .fixture(id: 25, name: "pikachu"),
                .fixture(id: 149, name: "dragonite")
            ]
        }
    }

    #Preview("一覧") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.list)))
        }
    }

    #Preview("読み込み中") {
        NavigationStack {
            HomeView(source: .snapshot(.loading))
        }
    }

    #Preview("続きを読み込み中") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.list), loadingMore: true))
        }
    }

    #Preview("知らせ付き") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.degradedList)))
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

    #Preview("文字を大きくしたとき") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.list)))
        }
        .environment(\.dynamicTypeSize, .accessibility3)
    }

    #Preview("文字を大きくしたときの読み込み中") {
        NavigationStack {
            HomeView(source: .snapshot(.loading))
        }
        .environment(\.dynamicTypeSize, .accessibility3)
    }
#endif
