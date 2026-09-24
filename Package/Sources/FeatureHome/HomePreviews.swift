#if DEBUG
    import ScreenCore
    import SharedCore
    import SwiftUI

    private enum PreviewData {
        static var pokemon: [Pokemon] {
            [
                .fixture(
                    id: 1,
                    name: "bulbasaur",
                    types: [.grass, .poison],
                    baseStats: .spread([45, 49, 49, 65, 65, 45])
                ),
                .fixture(id: 4, name: "charmander", types: [.fire], baseStats: .spread([39, 52, 43, 60, 50, 65])),
                .fixture(id: 7, name: "squirtle", types: [.water], baseStats: .spread([44, 48, 65, 50, 64, 43])),
                .fixture(id: 10, name: "caterpie", types: [.bug], baseStats: .spread([45, 30, 35, 20, 20, 45])),
                .fixture(id: 25, name: "pikachu", types: [.electric], baseStats: .spread([35, 55, 40, 50, 50, 90])),
                .fixture(
                    id: 149,
                    name: "dragonite",
                    types: [.dragon, .flying],
                    baseStats: .spread([91, 134, 95, 100, 100, 80])
                )
            ]
        }

        static var degraded: Pokemon {
            .incomplete(id: 132, name: "ditto")
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

    #Preview("文字を大きくしたとき") {
        NavigationStack {
            HomeView(source: .snapshot(.loaded(PreviewData.pokemon)))
        }
        .environment(\.dynamicTypeSize, .accessibility3)
    }
#endif
