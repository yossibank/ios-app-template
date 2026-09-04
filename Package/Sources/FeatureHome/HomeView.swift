import Core
import SwiftUI

public struct HomeView: View {
    @State private var result: PokemonListResult?

    public init() {}

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
        .task {
            // 失敗は Failed として返るため、throw はキャンセル時だけ。
            result = try? await PokemonApi().fetchPage(limit: 20, offset: 0)
        }
    }
}

#Preview {
    HomeView()
}
