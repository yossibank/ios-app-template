import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    private let source: ScreenSource<HomeViewModel>

    public init(_ source: ScreenSource<HomeViewModel> = .live(HomeViewModel())) {
        self.source = source
    }

    public var body: some View {
        ScreenView(source) { pokemon in
            List(pokemon, id: \.url) {
                Text($0.name)
            }
        }
    }
}

#Preview("一覧") {
    HomeView(.snapshot(.loaded([
        PokemonSummary(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
        PokemonSummary(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
        PokemonSummary(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/")
    ])))
}

#Preview("失敗") {
    HomeView(.snapshot(.failed(ScreenFailure("ネットワークに接続できません"))))
}

#Preview("読み込み中") {
    HomeView(.snapshot(.loading))
}
