import ScreenCore
import SharedCore
import SwiftUI

struct ProductLead: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProductThumbnail(product: product, inset: 20)
                .aspectRatio(16 / 11, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    ProductNumber(product: product, size: 12)
                        .padding(.leading, 14)
                        .padding(.top, 12)
                }

            HStack(alignment: .lastTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if let brand = product.brand {
                        BrandText(brand: brand, size: 12)
                    }

                    Text(product.title)
                        .font(.atelierMincho(19, relativeTo: .title3, bold: true))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Text(product.priceText())
                    .font(.atelierSerif(24, relativeTo: .title2, semibold: true))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("大きい 1 件") {
    ProductLead(product: Preview.products[5])
        .padding(20)
        .background(Color.atelierGround)
}

#Preview("大きい 1 件（ブランドなし）") {
    ProductLead(product: Preview.products[2])
        .padding(20)
        .background(Color.atelierGround)
}
