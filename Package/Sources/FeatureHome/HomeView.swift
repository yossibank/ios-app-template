import ScreenCore
import SharedCore
import SwiftUI

private let maxTotalBaseStat = 720.0
private let maxBaseStat = 255.0
private let skeletonCount = 8

private let gridColumns = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10)
]

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
        .environment(\.screenStyle, .standard.showingWhileLoading { SkeletonGrid() })
    }
}

public extension HomeView {
    init() {
        self.init(source: .live(HomeViewModel()))
    }
}

private struct HomeContent: View {
    @Bindable var viewState: HomeViewModel.State

    @State private var opened: PokemonEntry?

    let pokemon: [PokemonEntry]
    let actions: ScreenActions

    private var availableTypes: [PokemonTypeKind] {
        var seen: [PokemonTypeKind] = []

        for entry in pokemon {
            guard case let .loaded(detail) = onEnum(of: entry.detail) else {
                continue
            }

            for type in detail.types where !seen.contains(type) {
                seen.append(type)
            }
        }

        return seen
    }

    private var filtered: [PokemonEntry] {
        pokemon.filter { entry in
            let matchesName = viewState.query.isEmpty
                || entry.name.localizedStandardContains(viewState.query)

            return matchesName && entry.matches(viewState.selectedType)
        }
    }

    private var isFiltering: Bool {
        !viewState.query.isEmpty || viewState.selectedType != nil
    }

    var body: some View {
        let items = filtered
        let prefetch = Set(
            items
                .suffix(Int(PokemonPager.companion.PREFETCH_DISTANCE))
                .map(\.id)
        )

        ScrollView {
            LazyVStack(spacing: 12) {
                TypeFilters(types: availableTypes, selected: $viewState.selectedType)

                if viewState.incompleteCount > 0 {
                    Banner(
                        text: HomeStrings.incomplete(viewState.incompleteCount),
                        action: HomeStrings.retryDetails,
                        busy: actions.isRefilling
                    ) {
                        actions.refill()
                    }
                }

                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(items, id: \.id) { item in
                        PokemonCard(pokemon: item)
                            .onTapGesture { opened = item }
                            .onAppear {
                                guard !isFiltering, prefetch.contains(item.id) else {
                                    return
                                }

                                actions.loadMore()
                            }
                    }
                }

                if actions.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                if let notice = viewState.notice {
                    Banner(text: notice.message, color: .red) {
                        actions.reload()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .refreshable {
            await actions.refresh()
        }
        .overlay {
            if items.isEmpty {
                NoMatch(query: viewState.query, selectedType: viewState.selectedType)
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
        .sheet(item: $opened) { entry in
            PokemonSheet(pokemon: entry) { opened = nil }
        }
    }
}

private struct TypeFilters: View {
    let types: [PokemonTypeKind]

    @Binding var selected: PokemonTypeKind?

    var body: some View {
        if !types.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Chip(
                        text: HomeStrings.filterAll,
                        color: .secondary,
                        isOn: selected == nil
                    ) {
                        selected = nil
                    }

                    ForEach(types, id: \.self) { type in
                        Chip(
                            text: HomeStrings.typeName(type),
                            color: type.badgeColor,
                            isOn: selected == type
                        ) {
                            selected = selected == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct Chip: View {
    let text: String
    let color: Color
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isOn ? .white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isOn ? color : Color.secondary.opacity(0.15), in: Capsule())
        }
        .buttonStyle(.plain)
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
        .padding(.horizontal, 4)
    }
}

private struct PokemonCard: View {
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
        VStack(alignment: .leading, spacing: 0) {
            Text(HomeStrings.number(Int(pokemon.id)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Artwork(detail: detail, fallback: pokemon.name, accent: accent)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            Text(pokemon.name.capitalized)
                .font(.headline)
                .lineLimit(1)

            if let detail, !detail.types.isEmpty {
                HStack(spacing: 4) {
                    ForEach(detail.types, id: \.self) { type in
                        TypeBadge(type: type)
                    }
                }
                .padding(.top, 6)
            }

            if let detail, !detail.baseStats.isEmpty {
                HStack(spacing: 8) {
                    StatBar(stats: detail.baseStats, total: Int(detail.totalBaseStat))

                    Text(HomeStrings.total(Int(detail.totalBaseStat)))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(accent)
                        .monospacedDigit()
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.28), accent.opacity(0.06), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct Artwork: View {
    let detail: PokemonEntryDetailLoaded?
    let fallback: String
    let accent: Color

    private var large: URL? {
        (detail?.artworkUrl ?? detail?.spriteUrl).flatMap(URL.init(string:))
    }

    var body: some View {
        if let large {
            AsyncImage(
                url: large,
                transaction: Transaction(animation: .easeOut(duration: 0.2))
            ) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .transition(.opacity)
                } else {
                    Disc(accent: accent)
                }
            }
        } else {
            Initial(text: fallback)
        }
    }
}

private struct Disc: View {
    let accent: Color

    var body: some View {
        Circle()
            .fill(accent.opacity(0.12))
            .padding(14)
    }
}

private struct Initial: View {
    let text: String

    var body: some View {
        Text(text.prefix(1).uppercased())
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.secondary)
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

private struct PokemonSheet: View {
    let pokemon: PokemonEntry
    let onClose: () -> Void

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
        ScrollView {
            VStack(spacing: 12) {
                Text(HomeStrings.number(Int(pokemon.id)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                Text(pokemon.name.capitalized)
                    .font(.largeTitle.weight(.bold))

                Artwork(detail: detail, fallback: pokemon.name, accent: accent)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 260)

                if let detail, !detail.types.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(detail.types, id: \.self) { type in
                            TypeBadge(type: type)
                        }
                    }
                }

                if let detail {
                    HStack {
                        Text(HomeStrings.totalCaption)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(HomeStrings.total(Int(detail.totalBaseStat)))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(accent)
                            .monospacedDigit()
                    }
                    .padding(.top, 12)

                    ForEach(Array(detail.baseStats.enumerated()), id: \.offset) { _, stat in
                        StatRow(stat: stat)
                    }
                } else {
                    Text(HomeStrings.detailMissing)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }

                Button(HomeStrings.close, action: onClose)
                    .padding(.top, 16)
            }
            .padding(24)
        }
        .presentationDetents([.medium, .large])
    }
}

private struct StatRow: View {
    let stat: PokemonBaseStat

    private var fraction: Double {
        min(max(Double(stat.value) / maxBaseStat, 0.02), 1)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(HomeStrings.statName(stat.kind))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            Text("\(Int(stat.value))")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)

                    Capsule()
                        .fill(stat.kind.barColor)
                        .frame(width: geometry.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 3)
    }
}

private struct SkeletonGrid: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(0..<skeletonCount, id: \.self) { _ in
                    SkeletonCard()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollDisabled(true)
    }
}

private struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(width: 44, height: 12)

            Circle()
                .fill(.quaternary)
                .padding(12)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)

            SkeletonBlock(width: 96, height: 16)
                .padding(.top, 2)

            SkeletonBlock(width: 64, height: 12)
                .padding(.top, 8)

            SkeletonBlock(width: nil, height: 7)
                .padding(.top, 10)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct SkeletonBlock: View {
    let width: CGFloat?
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(.quaternary)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

private struct NoMatch: View {
    let query: String
    let selectedType: PokemonTypeKind?

    var body: some View {
        if selectedType != nil {
            ContentUnavailableView {
                Label(HomeStrings.noTypeMatch, systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text(HomeStrings.noTypeMatchDescription)
            }
        } else {
            ContentUnavailableView.search(text: query)
        }
    }
}

private struct TypeBadge: View {
    let type: PokemonTypeKind

    var body: some View {
        Text(HomeStrings.typeName(type))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(type.badgeColor, in: Capsule())
    }
}

private extension PokemonEntry {
    func matches(_ type: PokemonTypeKind?) -> Bool {
        guard let type else {
            return true
        }

        guard case let .loaded(detail) = onEnum(of: detail) else {
            return false
        }

        return detail.types.contains(type)
    }
}

extension PokemonEntry: @retroactive Identifiable {}

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
                artworkUrl: nil,
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

#Preview("読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loading))
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
