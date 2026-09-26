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
        }
        .navigationTitle(.homeTitle)
        .environment(\.screenStyle, .standard.showingWhileLoading { PokemonSkeletonGrid() })
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}
