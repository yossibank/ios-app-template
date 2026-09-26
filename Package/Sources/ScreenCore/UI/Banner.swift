import SwiftUI

public struct Banner: View {
    public enum Style: Sendable {
        case info
        case failure
    }

    private let text: String
    private let style: Style
    private let actionTitle: LocalizedStringResource
    private let isBusy: Bool
    private let action: (() -> Void)?

    private var tint: Color {
        switch style {
        case .info:
            .secondary

        case .failure:
            .red
        }
    }

    public init(
        text: String,
        style: Style = .info,
        actionTitle: LocalizedStringResource? = nil,
        isBusy: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.style = style
        self.actionTitle = actionTitle ?? .screenRetry
        self.isBusy = isBusy
        self.action = action
    }

    public var body: some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(tint)

            Spacer()

            if isBusy {
                ProgressView()
                    .controlSize(.small)
            } else if let action {
                Button(actionTitle, action: action)
                    .font(.footnote)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview("知らせ") {
    Banner(text: "8 件の詳細を取得できませんでした") {}
}

#Preview("知らせ（実行中）") {
    Banner(text: "8 件の詳細を取得できませんでした", isBusy: true) {}
}

#Preview("失敗の知らせ") {
    Banner(text: "接続を確認してください", style: .failure) {}
}
