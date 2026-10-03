import Foundation

public struct Product: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let thumbnail: URL?

    public init(
        id: Int,
        title: String,
        thumbnail: URL?
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
    }
}

public extension Product {
    static let placeholder = Product(
        id: 0,
        title: "Placeholder product title",
        thumbnail: nil
    )
}
