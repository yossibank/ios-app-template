import ScreenCore
import SharedCore
import SwiftUI

struct ProductThumbnail: View {
    let product: Product
    var inset: CGFloat = 16

    var body: some View {
        AsyncImage(
            url: product.thumbnail,
            transaction: Transaction(animation: .easeOut(duration: 0.3))
        ) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(inset)
                    .transition(.opacity)

            case .failure:
                Text(product.title.prefix(1).uppercased())
                    .font(.atelierSerif(40, relativeTo: .largeTitle, semibold: true))
                    .foregroundStyle(Color.atelierOnTile)

            default:
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.atelierTile)
        .accessibilityHidden(true)
    }
}

struct ProductNumber: View {
    let product: Product
    var size: CGFloat = 11

    var body: some View {
        Text(product.number)
            .font(.atelierSerif(size, relativeTo: .caption2, semibold: true))
            .tracking(size * 0.18)
            .foregroundStyle(Color.atelierOnTile)
    }
}

struct BrandText: View {
    let brand: String
    var size: CGFloat = 11

    var body: some View {
        Text(brand.uppercased())
            .font(.atelierSerif(size, relativeTo: .caption2, semibold: true))
            .tracking(size * 0.18)
            .foregroundStyle(Color.atelierMuted)
    }
}
