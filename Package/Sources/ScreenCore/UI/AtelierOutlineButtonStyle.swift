import SwiftUI

public struct AtelierOutlineButtonStyle: ButtonStyle {
    private let color: Color
    private let horizontalPadding: CGFloat
    private let minHeight: CGFloat

    public init(
        color: Color = .atelierInk,
        horizontalPadding: CGFloat = 36,
        minHeight: CGFloat = 48
    ) {
        self.color = color
        self.horizontalPadding = horizontalPadding
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.atelierMincho(14, relativeTo: .subheadline, bold: true))
            .tracking(2.4)
            .foregroundStyle(color)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: minHeight)
            .overlay {
                Rectangle()
                    .stroke(color, lineWidth: 1)
            }
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#Preview("線のボタン") {
    Button("再取得") {}
        .buttonStyle(AtelierOutlineButtonStyle())
        .padding()
        .background(Color.atelierGround)
}
