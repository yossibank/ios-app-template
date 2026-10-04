import Foundation

public struct Product: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let thumbnail: URL?
    public let brand: String?
    public let price: Double

    public init(
        id: Int,
        title: String,
        thumbnail: URL?,
        brand: String?,
        price: Double
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.brand = brand
        self.price = price
    }
}

public extension Product {
    static let placeholder = Product(
        id: 0,
        title: "Placeholder product title",
        thumbnail: nil,
        brand: "Placeholder",
        price: 0
    )
}
