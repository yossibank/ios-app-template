import SwiftUI
import UIKit

final class Artwork: Sendable {
    let image: UIImage
    let tint: Color

    init(image: UIImage, tint: Color) {
        self.image = image
        self.tint = tint
    }
}
