import SwiftUI

public struct CapsuleMeter: View {
    private let fraction: Double
    private let tint: Color

    public init(fraction: Double, tint: Color) {
        self.fraction = fraction
        self.tint = tint
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)

                Capsule()
                    .fill(tint)
                    .frame(width: geometry.size.width * fraction)
            }
        }
    }
}

#Preview("メーター") {
    VStack(spacing: 12) {
        CapsuleMeter(fraction: 0.2, tint: .green)
            .frame(height: 8)
        CapsuleMeter(fraction: 0.8, tint: .orange)
            .frame(height: 8)
    }
    .padding()
}
