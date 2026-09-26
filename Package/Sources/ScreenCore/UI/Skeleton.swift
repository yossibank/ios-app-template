import SwiftUI

public extension View {
    func skeleton() -> some View {
        redacted(reason: .placeholder)
            .modifier(Shimmer())
    }
}

private struct Shimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            TimelineView(.animation) { timeline in
                let progress = progress(at: timeline.date)

                content.mask {
                    linearGradient(progress: progress)
                }
            }
        }
    }
}

private extension Shimmer {
    func linearGradient(progress: Double) -> LinearGradient {
        LinearGradient(
            colors: [
                .black.opacity(0.6),
                .black,
                .black.opacity(0.6)
            ],
            startPoint: UnitPoint(x: progress * 2 - 1, y: 0.5),
            endPoint: UnitPoint(x: progress * 2, y: 0.5)
        )
    }
}

private extension Shimmer {
    func progress(at date: Date) -> Double {
        let elapsed = date
            .timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: 1.5)

        return elapsed / 1.5
    }
}

#Preview("スケルトン") {
    VStack(alignment: .leading, spacing: 4) {
        Text("#025")
            .font(.caption)

        Text("Pikachu")
            .font(.headline)

        Image(systemName: "info.circle")
            .resizable()
            .frame(width: 150, height: 150)
    }
    .skeleton()
}
