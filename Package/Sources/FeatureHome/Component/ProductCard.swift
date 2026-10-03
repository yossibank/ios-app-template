import SharedCore
import SwiftUI

struct ProductCard: View {
    @Environment(\.redactionReasons) private var redactionReasons

    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            thumbnail

            Text(product.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2, reservesSpace: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4))
        .clipShape(.rect(cornerRadius: 16))
    }
}

private extension ProductCard {
    var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    var thumbnail: some View {
        AsyncImage(
            url: isPlaceholder ? nil : product.thumbnail,
            transaction: Transaction(animation: .easeOut(duration: 0.3))
        ) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .transition(.opacity)

            case .failure where !isPlaceholder:
                Text(product.title.prefix(1).uppercased())
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.secondary)

            default:
                Color.clear
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(.background, in: .rect(cornerRadius: 12))
    }
}

#Preview("カード") {
    ProductCard(product: Product(id: 1, title: "Essence Mascara Lash Princess", thumbnail: nil))
        .frame(width: 160)
}

#Preview("カード（読み込み中）") {
    ProductCard(product: .placeholder)
        .redacted(reason: .placeholder)
        .frame(width: 160)
}
