import Foundation

actor ArtworkStore {
    static let shared = ArtworkStore()

    private let cache = NSCache<NSURL, Artwork>()

    private init() {
        cache.countLimit = 200
    }
}

extension ArtworkStore {
    func artwork(for url: URL) async -> Artwork? {
        if let artwork = cache.object(forKey: url as NSURL) {
            return artwork
        }

        guard
            let (data, _) = try? await URLSession.shared.data(from: url),
            let artwork = ArtworkDecoder.artwork(from: data)
        else {
            return nil
        }

        cache.setObject(artwork, forKey: url as NSURL)

        return artwork
    }
}
