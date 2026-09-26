import SwiftUI

public extension View {
    func skeleton() -> some View {
        redacted(reason: .placeholder)
            .modifier(Shimmer())
    }
}

private struct Shimmer: ViewModifier {
    private static let duration = 1.4
    private static let dimmedOpacity = 0.6

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            TimelineView(.animation) { timeline in
                let progress = timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: Self.duration) / Self.duration

                content.mask {
                    LinearGradient(
                        colors: [
                            .black.opacity(Self.dimmedOpacity),
                            .black,
                            .black.opacity(Self.dimmedOpacity)
                        ],
                        startPoint: UnitPoint(x: progress * 2 - 1, y: 0.5),
                        endPoint: UnitPoint(x: progress * 2, y: 0.5)
                    )
                }
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
