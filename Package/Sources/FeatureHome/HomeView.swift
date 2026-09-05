import Core
import SwiftUI

public struct HomeView: View {
    private let load: () async -> PokemonListResult?

    @State private var result: PokemonListResult?

    /// 失敗は Failed として返るため、throw はキャンセル時だけ。
    public init() {
        self.init { try? await PokemonApi().fetchPage(limit: 20, offset: 0) }
    }

    public init(load: @escaping () async -> PokemonListResult?) {
        self.load = load
    }

    public var body: some View {
        Group {
            if let result {
                switch onEnum(of: result) {
                case let .loaded(loaded):
                    List(loaded.pokemon, id: \.url) { pokemon in
                        Text(pokemon.name)
                    }

                case let .failed(failed):
                    ContentUnavailableView(
                        "読み込めませんでした",
                        systemImage: "exclamationmark.triangle",
                        description: Text(failed.message)
                    )
                }
            } else {
                ProgressView()
            }
        }
        .task { result = await load() }
    }
}

#Preview("一覧") {
    Text("HOGE")
//    HomeView {
//        PokemonListResultLoaded(
//            pokemon: [
//                PokemonSummary(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
//                PokemonSummary(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
//                PokemonSummary(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/")
//            ],
//            hasMore: true
//        )
//    }
}

#Preview("失敗") {
    HomeView { PokemonListResultFailed(message: "ネットワークに接続できません") }
}

#Preview("読み込み中") {
    HomeView { nil }
}
