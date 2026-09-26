import CoreImage
import Foundation

actor ArtworkStore {
    static let shared = ArtworkStore()

    private let cache = NSCache<NSURL, Entry>()
    private let context = CIContext()

    init() {
        cache.countLimit = 200
    }

    func artwork(for url: URL) async -> Artwork? {
        if let entry = cache.object(forKey: url as NSURL) {
            return entry.artwork
        }

        guard
            let (data, _) = try? await URLSession.shared.data(from: url),
            let artwork = ArtworkDecoder.artwork(from: data, context: context)
        else {
            return nil
        }

        cache.setObject(Entry(artwork), forKey: url as NSURL)

        return artwork
    }
}

private final class Entry {
    let artwork: Artwork

    init(_ artwork: Artwork) {
        self.artwork = artwork
    }
}
