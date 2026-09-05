import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    private let source: ScreenSource<HomeViewModel>

    public init(_ source: ScreenSource<HomeViewModel> = .live(HomeViewModel())) {
        self.source = source
    }

    public var body: some View {
        NavigationStack {
            ScreenView(source) { viewState, pokemon in
                HomeContent(viewState: viewState, pokemon: pokemon)
            }
            .navigationTitle("ポケモン")
        }
    }
}

private struct HomeContent: View {
    @Environment(\.screenReload) private var reload

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
        List(filtered, id: \.url) {
            Text($0.name)
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
    HomeView(.snapshot(.loaded([
        PokemonSummary(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
        PokemonSummary(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
        PokemonSummary(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/")
    ])))
}
