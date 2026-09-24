import SwiftUI

public struct SkeletonBlock: View {
    private let width: CGFloat?
    private let height: CGFloat

    public init(width: CGFloat? = nil, height: CGFloat) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        Capsule()
            .fill(.quaternary)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

#Preview("骨組み") {
    VStack(alignment: .leading, spacing: 8) {
        SkeletonBlock(width: 44, height: 12)
        SkeletonBlock(width: 96, height: 16)
        SkeletonBlock(height: 7)
    }
    .padding()
}
