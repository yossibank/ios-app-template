import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import SwiftUI
import UIKit

enum ArtworkDecoder {
    static func artwork(from data: Data, context: CIContext) -> Artwork? {
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

        let tint = tint(of: image, context: context).map(Color.init(uiColor:)) ?? .accentColor

        return Artwork(image: UIImage(cgImage: image), tint: tint)
    }

    static func tint(of image: CGImage, context: CIContext) -> UIColor? {
        let input = CIImage(cgImage: image)
        let filter = CIFilter.areaAverage()
        filter.inputImage = input
        filter.extent = input.extent

        guard let output = filter.outputImage else {
            return nil
        }

        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(
            output,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )

        let alpha = CGFloat(pixel[3]) / 255

        guard alpha > 0.01 else {
            return nil
        }

        let average = UIColor(
            red: min(CGFloat(pixel[0]) / 255 / alpha, 1),
            green: min(CGFloat(pixel[1]) / 255 / alpha, 1),
            blue: min(CGFloat(pixel[2]) / 255 / alpha, 1),
            alpha: 1
        )

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        average.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        return UIColor(
            hue: hue,
            saturation: max(saturation, 0.45),
            brightness: min(max(brightness, 0.55), 0.9),
            alpha: 1
        )
    }
}
