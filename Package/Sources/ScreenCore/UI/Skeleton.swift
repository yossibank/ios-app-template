import SwiftUI

public extension View {
    func skeleton() -> some View {
        redacted(reason: .placeholder)
            .modifier(Shimmer())
    }
}

private struct Shimmer: ViewModifier {
    private static let duration = 1.4
    private static let bandRatio = 0.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.overlay {
                TimelineView(.animation) { timeline in
                    GeometryReader { proxy in
                        let progress = timeline.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: Self.duration) / Self.duration
                        let band = proxy.size.width * Self.bandRatio

                        LinearGradient(
                            colors: [.clear, .white.opacity(0.35), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: band)
                        .offset(x: -band + progress * (proxy.size.width + band))
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
            }
        }
    }
}

#Preview("骨組み") {
    VStack(alignment: .leading, spacing: 8) {
        Text("#025")
            .font(.caption)
        Text("Pikachu")
            .font(.headline)
    }
    .skeleton()
    .padding()
}
