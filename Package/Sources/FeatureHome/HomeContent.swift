import ScreenCore
import SharedCore
import SwiftUI

struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var refreshes = 0
    @State private var isRefreshing = false

    let list: PokemonList
    let actions: ScreenActions

    private var filtered: [Pokemon] {
        list.pokemon.filtered(query: viewState.query)
    }

    private var isFiltering: Bool {
        !viewState.query.isEmpty
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(8)
                .map(\.id)
        )
        let distantScale = reduceMotion ? 1 : 0.94

        ScrollView {
            LazyVStack(spacing: 12) {
                PokemonGrid {
                    ForEach(items) { item in
                        PokemonCard(pokemon: item)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : distantScale)
                                    .opacity(phase.isIdentity ? 1 : 0.6)
                            }
                            .onAppear {
                                guard
                                    !isFiltering,
                                    list.notice == nil,
                                    prefetch.contains(item.id)
                                else {
                                    return
                                }

                                actions.loadMore()
                            }
                    }
                }

                if actions.isLoadingMore, list.notice == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                if let notice = list.notice {
                    Banner(
                        text: notice.message,
                        style: .failure,
                        accessory: actions.isLoadingMore || isRefreshing
                            ? .progress
                            : .retry { retry(after: notice) }
                    )
                }
            }
            .pokemonContentInsets()
        }
        .safeAreaInset(edge: .bottom) {
            PokemonListToolbar(
                shown: items.count,
                loaded: list.pokemon.count,
                total: list.total,
                filtering: isFiltering
            )
            .padding(.bottom, 8)
        }
        .refreshable {
            await refresh()
        }
        .sensoryFeedback(.success, trigger: refreshes)
        .sensoryFeedback(trigger: list.notice) { _, notice in
            notice == nil ? nil : .error
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView.search(text: viewState.query)
            }
        }
        .searchable(
            text: $viewState.query,
            prompt: .homeSearchPrompt
        )
        .toolbar {
            Button(.homeReload, systemImage: "arrow.clockwise") {
                Task {
                    await refresh()
                }
            }
            .disabled(isRefreshing)
        }
    }

    private func refresh() async {
        isRefreshing = true
        await actions.refresh()
        isRefreshing = false
        refreshes += 1
    }

    private func retry(after notice: FetchFailure) {
        if notice.canRetry {
            actions.loadMore()
        } else {
            Task {
                await refresh()
            }
        }
    }
}
