import ImageIO
import SharedCore
import SwiftUI
import UIKit

enum ArtworkDecoder {
    static func artwork(from data: Data) -> Artwork? {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(
                source,
                0,
                [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: 320
                ] as CFDictionary
            )
        else {
            return nil
        }

        return Artwork(
            image: UIImage(cgImage: image),
            tint: tint(of: image) ?? .accentColor
        )
    }

    static func tint(of image: CGImage) -> Color? {
        guard let tint = Tint(argb: pixels(of: image)) else {
            return nil
        }

        return Color(
            hue: tint.hue,
            saturation: tint.saturation,
            brightness: tint.brightness
        )
    }
}

private extension ArtworkDecoder {
    static func pixels(of image: CGImage) -> [Int32] {
        let size = 32

        var pixels = [UInt8](repeating: 0, count: size * size * 4)

        guard
            let space = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: &pixels,
                width: size,
                height: size,
                bitsPerComponent: 8,
                bytesPerRow: size * 4,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            return []
        }

        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: size, height: size)
        )

        return stride(from: 0, to: pixels.count, by: 4).map { index -> Int32 in
            let alpha = UInt32(pixels[index + 3])

            guard alpha > 0 else {
                return 0
            }

            let red = UInt32(pixels[index]) * 255 / alpha
            let green = UInt32(pixels[index + 1]) * 255 / alpha
            let blue = UInt32(pixels[index + 2]) * 255 / alpha

            return Int32(bitPattern: alpha << 24 | red << 16 | green << 8 | blue)
        }
    }
}
