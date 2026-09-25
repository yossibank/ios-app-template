#if DEBUG
    import Foundation

    public extension Pokemon {
        static func fixture(id: Int, name: String, artwork: URL? = nil) -> Pokemon {
            Pokemon(id: id, name: name, artwork: artwork)
        }
    }
#endif
