import ImageIO
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
        guard let dominant = dominantColor(of: image)?.hsb else {
            return nil
        }

        return Color(
            hue: dominant.hue,
            saturation: max(dominant.saturation, 0.45),
            brightness: min(max(dominant.brightness, 0.55), 0.9)
        )
    }
}

private extension ArtworkDecoder {
    static func dominantColor(of image: CGImage) -> RGB? {
        var buckets = [Bucket](repeating: Bucket(), count: 12)

        for pixel in opaquePixels(of: image) {
            let hsb = pixel.hsb

            guard
                hsb.saturation > 0.2,
                hsb.brightness > 0.2
            else {
                continue
            }

            let index = min(Int(hsb.hue * 12), 11)
            buckets[index].weight += hsb.saturation
            buckets[index].sum.red += pixel.red * hsb.saturation
            buckets[index].sum.green += pixel.green * hsb.saturation
            buckets[index].sum.blue += pixel.blue * hsb.saturation
        }

        guard
            let bucket = buckets.max(by: { $0.weight < $1.weight }),
            bucket.weight > 0
        else {
            return nil
        }

        return RGB(
            red: bucket.sum.red / bucket.weight,
            green: bucket.sum.green / bucket.weight,
            blue: bucket.sum.blue / bucket.weight
        )
    }

    static func opaquePixels(of image: CGImage) -> [RGB] {
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

        return stride(from: 0, to: pixels.count, by: 4).compactMap { index in
            let alpha = Double(pixels[index + 3])

            guard alpha > 127 else {
                return nil
            }

            return RGB(
                red: Double(pixels[index]) / alpha,
                green: Double(pixels[index + 1]) / alpha,
                blue: Double(pixels[index + 2]) / alpha
            )
        }
    }
}

private extension ArtworkDecoder {
    struct RGB {
        var red = 0.0
        var green = 0.0
        var blue = 0.0

        var hsb: HSB {
            let maximum = max(red, green, blue)
            let delta = maximum - min(red, green, blue)

            guard delta > 0 else {
                return HSB(hue: 0, saturation: 0, brightness: maximum)
            }

            let sector = switch maximum {
            case red: (green - blue) / delta
            case green: (blue - red) / delta + 2
            default: (red - green) / delta + 4
            }

            let hue = (sector / 6).truncatingRemainder(dividingBy: 1)

            return HSB(
                hue: hue < 0 ? hue + 1 : hue,
                saturation: delta / maximum,
                brightness: maximum
            )
        }
    }

    struct HSB {
        let hue: Double
        let saturation: Double
        let brightness: Double
    }

    struct Bucket {
        var weight = 0.0
        var sum = RGB()
    }
}
