import SwiftUI

enum PokemonMetrics {
    static let maxTotalBaseStat = 720.0
    static let maxBaseStat = 255.0
    static let skeletonCount = 8

    static let cardCornerRadius = 20.0
    static let cardSpacing = 10.0
    static let contentInset = 12.0
    static let contentTopInset = 8.0
    static let minimumCardWidth = 150.0

    static let gridColumns = [
        GridItem(.adaptive(minimum: minimumCardWidth), spacing: cardSpacing)
    ]

    static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardCornerRadius)
    }
}
