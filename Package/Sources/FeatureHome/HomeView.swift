import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    let source: ScreenSource<HomeViewModel>
    var onLogout: () -> Void = {}

    public var body: some View {
        ScreenView(source, isEmpty: \.products.isEmpty) { viewState, list, actions in
            HomeContent(
                viewState: viewState,
                list: list,
                actions: actions
            )
        } empty: { actions in
            empty(actions)
        } loading: {
            skeleton
        }
        .navigationTitle(.homeTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(.homeLogout, action: onLogout)
            }
        }
    }
}

public extension HomeView {
    init(onLogout: @escaping () -> Void) {
        self.init(source: .live(HomeViewModel()), onLogout: onLogout)
    }
}

private extension HomeView {
    func empty(_ actions: ScreenActions) -> some View {
        ContentUnavailableView {
            Label(.homeEmptyTitle, systemImage: "tray")
        } description: {
            Text(.homeEmptyDescription)
        } actions: {
            Button(.homeReload) {
                actions.reload()
            }
        }
    }

    var skeleton: some View {
        ScrollView {
            ProductGrid {
                ForEach(0..<8, id: \.self) { _ in
                    ProductCard(product: .placeholder)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .skeleton()
        }
        .scrollDisabled(true)
    }
}

enum Preview {
    static var list: ProductList {
        ProductList(products: products, total: 194)
    }

    static var listWithError: ProductList {
        ProductList(products: products, total: 194, notice: .offline)
    }

    static var products: [Product] {
        [
            "Essence Mascara Lash Princess",
            "Eyeshadow Palette with Mirror",
            "Powder Canister",
            "Red Lipstick",
            "Red Nail Polish",
            "Calvin Klein CK One"
        ].enumerated().map { index, title in
            Product(id: index + 1, title: title, thumbnail: nil)
        }
    }
}

#Preview("一覧") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.list)))
    }
}

#Preview("読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loading))
    }
}

#Preview("続きを読み込み中") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.list), loadingMore: true))
    }
}

#Preview("バナー付き") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.listWithError)))
    }
}

#Preview("失敗") {
    NavigationStack {
        HomeView(source: .snapshot(.failed(.offline)))
    }
}

#Preview("空") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(ProductList(products: [], total: 0))))
    }
}
