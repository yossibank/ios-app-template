import ScreenCore
import SharedCore
import SwiftUI

private let maxTotalBaseStat = 720.0

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
            if viewState.incompleteCount > 0 {
                Banner(
                    text: HomeStrings.incomplete(viewState.incompleteCount),
                    action: HomeStrings.retryDetails,
                    busy: actions.isRefilling
                ) {
                    actions.refill()
                }
            }

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

            if let notice = viewState.notice {
                Banner(text: notice.message, color: .red) {
                    actions.reload()
                }
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

private struct Banner: View {
    let text: String

    var color: Color = .secondary
    var action: String = HomeStrings.reload
    var busy = false

    var retry: (() -> Void)?

    var body: some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(color)

            Spacer()

            if busy {
                ProgressView()
                    .controlSize(.small)
            } else if let retry {
                Button(action, action: retry)
                    .font(.footnote)
            }
        }
        .listRowSeparator(.hidden)
    }
}

private struct PokemonRow: View {
    let pokemon: PokemonEntry

    private var detail: PokemonEntryDetailLoaded? {
        guard case let .loaded(detail) = onEnum(of: pokemon.detail) else {
            return nil
        }
        return detail
    }

    private var accent: Color {
        detail?.types.first?.badgeColor ?? .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Sprite(pokemon: pokemon, accent: accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(HomeStrings.number(Int(pokemon.id)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    Text(pokemon.name.capitalized)
                        .font(.headline)

                    if let detail, !detail.types.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(detail.types, id: \.self) { type in
                                TypeBadge(type: type)
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                if let detail, !detail.baseStats.isEmpty {
                    VStack(spacing: 0) {
                        Text(HomeStrings.total(Int(detail.totalBaseStat)))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(accent)
                            .monospacedDigit()

                        Text(HomeStrings.totalCaption)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let detail, !detail.baseStats.isEmpty {
                StatBar(stats: detail.baseStats, total: Int(detail.totalBaseStat))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.20), accent.opacity(0.04), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 18))
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
}

private struct StatBar: View {
    let stats: [PokemonBaseStat]
    let total: Int

    private var fraction: Double {
        min(max(Double(total) / maxTotalBaseStat, 0.04), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width * fraction
            let spread = max(stats.reduce(0) { $0 + max(Int($1.value), 1) }, 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)

                HStack(spacing: 0) {
                    ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                        Rectangle()
                            .fill(stat.kind.barColor)
                            .frame(width: width * Double(max(Int(stat.value), 1)) / Double(spread))
                    }
                }
                .clipShape(Capsule())
            }
        }
        .frame(height: 7)
    }
}

private struct Sprite: View {
    let pokemon: PokemonEntry
    let accent: Color

    private var spriteUrl: URL? {
        guard case let .loaded(detail) = onEnum(of: pokemon.detail) else {
            return nil
        }
        return detail.spriteUrl.flatMap(URL.init(string:))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.38), accent.opacity(0.10)],
                        center: .center,
                        startRadius: 2,
                        endRadius: 34
                    )
                )

            if let url = spriteUrl {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .padding(4)
            } else {
                Text(pokemon.name.prefix(1).uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 66, height: 66)
    }
}

private struct TypeBadge: View {
    let type: PokemonTypeKind

    var body: some View {
        Text(HomeStrings.typeName(type))
            .font(.caption2.weight(.semibold))
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
            entry(id: 25, name: "pikachu", types: [.electric], stats: [35, 55, 40, 50, 50, 90]),
            entry(id: 149, name: "dragonite", types: [.dragon, .flying], stats: [91, 134, 95, 100, 100, 80])
        ]
    }

    static var degraded: PokemonEntry {
        PokemonEntry(
            id: 132,
            name: "ditto",
            detail: PokemonEntryDetailMissing(failure: PokemonFailureServer(statusCode: 500))
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
            detail: PokemonEntryDetailLoaded(
                spriteUrl: nil,
                types: types,
                baseStats: zip(kinds, stats).map { PokemonBaseStat(kind: $0, value: $1) }
            )
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
        HomeView(source: .snapshot(.loaded([PreviewData.degraded] + PreviewData.pokemon)))
    }
}

#Preview("空") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded([])))
    }
}
