import CoreImage
@testable import FeatureHome
import Testing
import UIKit

struct ArtworkDecoderTests {
    @Test("透明な背景に引きずられず、描かれている色を取る")
    func tintIgnoresTheTransparentBackground() throws {
        let image = try #require(halfFilledImage(with: .red))

        let tint = try #require(ArtworkDecoder.tint(of: image, context: CIContext()))

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        tint.getRed(&red, green: &green, blue: &blue, alpha: nil)

        #expect(red > 0.8, "背景の透明分で暗くなっている")
        #expect(green < 0.2)
        #expect(blue < 0.2)
    }

    @Test("すべて透明なら色を決めない")
    func fullyTransparentHasNoTint() throws {
        let image = try #require(halfFilledImage(with: .clear))

        #expect(ArtworkDecoder.tint(of: image, context: CIContext()) == nil)
    }

    private func halfFilledImage(with color: UIColor) -> CGImage? {
        let size = 10
        let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size / 2, height: size))
        return context?.makeImage()
    }
}
