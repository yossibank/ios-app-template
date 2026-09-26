import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>

    public var body: some View {
        ScreenView(source, isEmpty: \.pokemon.isEmpty) { viewState, list, actions in
            HomeContent(
                viewState: viewState,
                list: list,
                actions: actions
            )
        } empty: { actions in
            ContentUnavailableView {
                Label(.homeEmptyTitle, systemImage: "tray")
            } description: {
                Text(.homeEmptyDescription)
            } actions: {
                Button(.homeReload) {
                    actions.reload()
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
