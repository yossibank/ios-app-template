import ScreenCore
import SharedCore
import SwiftUI

struct ProductTile: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProductThumbnail(product: product)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    ProductNumber(product: product)
                        .padding(.leading, 10)
                        .padding(.top, 9)
                }

            VStack(alignment: .leading, spacing: 3) {
                if let brand = product.brand {
                    BrandText(brand: brand)
                }

                Text(product.title)
                    .font(.atelierMincho(13, relativeTo: .subheadline))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(product.priceText())
                    .font(.atelierSerif(16, relativeTo: .callout, semibold: true))
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("小さい 2 件") {
    HStack(alignment: .top, spacing: 16) {
        ProductTile(product: Preview.products[3])
        ProductTile(product: Preview.products[2])
    }
    .padding(20)
    .background(Color.atelierGround)
}
