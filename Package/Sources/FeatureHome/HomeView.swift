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
                Label(HomeStrings.emptyTitle, systemImage: "tray")
            } description: {
                Text(HomeStrings.emptyDescription)
            } actions: {
                Button(HomeStrings.reload) {
                    actions.reload()
                }
            }
        }
        .navigationTitle(HomeStrings.title)
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    let pokemon: [PokemonEntry]
    let actions: ScreenActions

    private var filtered: [PokemonEntry] {
        guard !viewState.query.isEmpty else {
            return pokemon
        }

        return pokemon.filter {
            $0.name.localizedStandardContains(viewState.query)
        }
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(Int(PokemonPager.companion.PREFETCH_DISTANCE))
                .map(\.id)
        )

        List {
            ForEach(items, id: \.id) { item in
                PokemonRow(pokemon: item)
                    .onAppear {
                        guard viewState.query.isEmpty, prefetch.contains(item.id) else {
                            return
                        }

                        actions.loadMore()
                    }
            }

            if actions.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .listStyle(.plain)
        .overlay {
            if items.isEmpty {
                ContentUnavailableView.search(text: viewState.query)
            }
        }
        .searchable(
            text: $viewState.query,
            prompt: HomeStrings.searchPrompt
        )
        .toolbar {
            Button(HomeStrings.reload, systemImage: "arrow.clockwise") {
                actions.reload()
            }
        }
    }
}

private struct PokemonRow: View {
    let pokemon: PokemonEntry

    var body: some View {
        HStack(spacing: 12) {
            Sprite(pokemon: pokemon)

            VStack(alignment: .leading, spacing: 6) {
                Text(pokemon.name)
                    .font(.headline)

                if !pokemon.types.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(pokemon.types, id: \.self) { type in
                            TypeBadge(type: type)
                        }
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(HomeStrings.number(Int(pokemon.id)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                if !pokemon.baseStats.isEmpty {
                    Text(HomeStrings.total(Int(pokemon.totalBaseStat)))
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct Sprite: View {
    let pokemon: PokemonEntry

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)

            if let url = pokemon.spriteUrl.flatMap(URL.init(string:)) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text(pokemon.name.prefix(1))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 56, height: 56)
    }
}

private struct TypeBadge: View {
    let type: PokemonTypeKind

    var body: some View {
        Text(HomeStrings.typeName(type))
            .font(.caption2)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(type.badgeColor, in: Capsule())
    }
}

private enum PreviewData {
    static var pokemon: [PokemonEntry] {
        [
            entry(id: 1, name: "bulbasaur", types: [.grass, .poison], stats: [45, 49, 49, 65, 65, 45]),
            entry(id: 4, name: "charmander", types: [.fire], stats: [39, 52, 43, 60, 50, 65]),
            entry(id: 7, name: "squirtle", types: [.water], stats: [44, 48, 65, 50, 64, 43]),
            entry(id: 10, name: "caterpie", types: [.bug], stats: [45, 30, 35, 20, 20, 45]),
            entry(id: 25, name: "pikachu", types: [.electric], stats: [35, 55, 40, 50, 50, 90])
        ]
    }

    static var degraded: PokemonEntry {
        PokemonEntry(
            id: 132,
            name: "ditto",
            spriteUrl: nil,
            types: [],
            baseStats: []
        )
    }

    private static func entry(
        id: Int32,
        name: String,
        types: [PokemonTypeKind],
        stats: [Int32]
    ) -> PokemonEntry {
        let kinds: [PokemonStatKind] = [
            .hp, .attack, .defense, .specialAttack, .specialDefense, .speed
        ]

        return PokemonEntry(
            id: id,
            name: name,
            spriteUrl: nil,
            types: types,
            baseStats: zip(kinds, stats).map { PokemonBaseStat(kind: $0, value: $1) }
        )
    }
}

#Preview("一覧") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(PreviewData.pokemon)))
    }
}

#Preview("続きを読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loadingMore(PreviewData.pokemon)))
    }
}

#Preview("詳細を引けなかった行") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded([PreviewData.degraded])))
    }
}

#Preview("空") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded([])))
    }
}
