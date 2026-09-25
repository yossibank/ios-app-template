#if DEBUG
    import ScreenCore
    import SharedCore
    import SwiftUI

    private enum PreviewData {
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
            HomeView(source: .snapshot(.loaded(PreviewData.pokemon), running: [.loadMore]))
        }
    }

    #Preview("空") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded([])))
        }
    }

    #Preview("文字を大きくしたとき") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.pokemon)))
        }
        .environment(\.dynamicTypeSize, .accessibility3)
    }
#endif
