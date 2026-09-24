import SwiftUI

public struct Chip: View {
    private let text: String
    private let tint: Color
    private let isOn: Bool
    private let action: () -> Void

    public init(
        text: String,
        tint: Color,
        isOn: Bool,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.tint = tint
        self.isOn = isOn
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isOn ? .white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isOn ? tint : Color.secondary.opacity(0.15), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

#Preview("選んでいない") {
    Chip(text: "くさ", tint: .green, isOn: false) {}
}

#Preview("選んでいる") {
    Chip(text: "くさ", tint: .green, isOn: true) {}
}
