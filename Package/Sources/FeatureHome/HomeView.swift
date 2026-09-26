import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>

    public var body: some View {
        ScreenView(source) { viewState, pokemon, actions in
            HomeContent(
                viewState: viewState,
                pokemon: pokemon,
                actions: actions
            )
        } empty: { actions in
            ContentUnavailableView {
                Label(.homeEmptyTitle, systemImage: "tray")
            } description: {
                Text(.homeEmptyDescription)
            } actions: {
                Button(.homeReload) {
                    actions.request(.reload)
                }
            }
        } loading: {
            PokemonSkeletonGrid()
        }
        .navigationTitle(.homeTitle)
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}
