import ScreenCore
import SharedCore
import SwiftUI

struct ProductRow: View {
    let product: Product
    let query: String

    var body: some View {
        HStack(spacing: 16) {
            ProductThumbnail(product: product, inset: 10)
                .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 4) {
                if let brand = product.brand {
                    BrandText(brand: brand)
                }

                Text(product.highlightedTitle(matching: query))
                    .font(.atelierMincho(15, relativeTo: .body))

                Text(product.priceText())
                    .font(.atelierSerif(18, relativeTo: .body, semibold: true))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.atelierLine)
                .frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("検索結果の行") {
    VStack(spacing: 0) {
        ProductRow(product: Preview.products[3], query: "Red")
        ProductRow(product: Preview.products[4], query: "Red")
    }
    .padding(.horizontal, 20)
    .background(Color.atelierGround)
}
