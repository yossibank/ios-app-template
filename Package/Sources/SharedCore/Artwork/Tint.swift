import Shared

public struct Tint: Hashable, Sendable {
    public let hue: Double
    public let saturation: Double
    public let brightness: Double
}

public extension Tint {
    init?(argb: [Int32]) {
        let pixels = KotlinIntArray(size: Int32(argb.count))

        for (index, value) in argb.enumerated() {
            pixels.set(index: Int32(index), value: value)
        }

        guard let tint = ArtworkTint.Companion.shared.of(argb: pixels) else {
            return nil
        }

        self.init(
            hue: tint.hue,
            saturation: tint.saturation,
            brightness: tint.brightness
        )
    }
}
