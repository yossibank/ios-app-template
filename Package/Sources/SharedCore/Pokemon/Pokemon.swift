import Foundation

public struct Pokemon: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let artwork: URL?

    public init(
        id: Int,
        name: String,
        artwork: URL?
    ) {
        self.id = id
        self.name = name
        self.artwork = artwork
    }
}
