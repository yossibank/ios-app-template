import ScreenCore
import SharedCore
import SwiftUI

public struct HomeView: View {
    @State private var total: Int?

    let source: ScreenSource<HomeViewModel>
    var onLogout: () -> Void = {}

    public var body: some View {
        VStack(spacing: 0) {
            HomeHeader(total: total, onLogout: onLogout)

            ScreenView(source, isEmpty: \.products.isEmpty) { viewState, list, actions in
                HomeContent(
                    viewState: viewState,
                    list: list,
                    actions: actions
                )
                .onChange(of: list.total, initial: true) { _, value in
                    total = value
                }
            } empty: { actions in
                empty(actions)
            } loading: {
                skeleton
            }
        }
        .foregroundStyle(Color.atelierInk)
        .background(Color.atelierGround)
        .toolbar(.hidden, for: .navigationBar)
    }
}

public extension HomeView {
    init(onLogout: @escaping () -> Void) {
        self.init(source: .live(HomeViewModel()), onLogout: onLogout)
    }
}

private extension HomeView {
    func empty(_ actions: ScreenActions) -> some View {
        VStack(spacing: 18) {
            Rectangle()
                .fill(Color.atelierInk)
                .frame(width: 40, height: 1)

            Text(.homeEmptyTitle)
                .font(.atelierMincho(20, relativeTo: .title3, bold: true))

            Text(.homeEmptyDescription)
                .font(.footnote)
                .foregroundStyle(Color.atelierMuted)
                .multilineTextAlignment(.center)

            Button(action: actions.reload) {
                Text(.homeReload)
            }
            .buttonStyle(AtelierOutlineButtonStyle())
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var skeleton: some View {
        VStack(alignment: .leading, spacing: 26) {
            Rectangle()
                .fill(Color.atelierLine)
                .frame(height: 1)
                .padding(.top, 34)

            LeadSkeleton()

            HStack(alignment: .top, spacing: 16) {
                TileSkeleton()
                TileSkeleton()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .clipped()
    }
}

enum Preview {
    static var list: ProductList {
        ProductList(products: products, total: 194, pageSize: 20)
    }

    static var listWithError: ProductList {
        ProductList(products: products, total: 194, pageSize: 20, notice: .offline)
    }

    static var products: [Product] {
        [
            (1, "Essence Mascara Lash Princess", "Essence", 9.99),
            (2, "Eyeshadow Palette with Mirror", "Glamour Beauty", 19.99),
            (16, "Apple", nil, 1.99),
            (4, "Red Lipstick", "Chic Cosmetics", 12.99),
            (5, "Red Nail Polish", "Nail Couture", 8.99),
            (6, "Calvin Klein CK One", "Calvin Klein", 49.99)
        ].map { id, title, brand, price in
            Product(id: id, title: title, thumbnail: nil, brand: brand, price: price)
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

#Preview("続きの失敗") {
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
        HomeView(source: .snapshot(.loaded(ProductList(products: [], total: 0, pageSize: 20))))
    }
}

#Preview("ダーク") {
    NavigationStack {
        HomeView(source: .snapshot(.loaded(Preview.list)))
    }
    .preferredColorScheme(.dark)
}
