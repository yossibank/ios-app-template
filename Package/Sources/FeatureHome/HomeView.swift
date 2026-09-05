import Core
import SwiftUI

public struct HomeView: View {
    @State private var model: HomeViewModel

    public init(model: HomeViewModel = HomeViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        PhaseView(model) { pokemon in
            List(pokemon, id: \.url) { Text($0.name) }
        }
        .task { await model.load() }
    }
}

#Preview("一覧") {
    HomeView(model: HomeViewModel(phase: .loaded([
        PokemonSummary(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
        PokemonSummary(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
        PokemonSummary(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/")
    ])))
}

#Preview("失敗") {
    HomeView(model: HomeViewModel(phase: .failed("ネットワークに接続できません")))
}

#Preview("読み込み中") {
    HomeView(model: HomeViewModel(phase: .loading))
}
