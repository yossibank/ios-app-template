import SwiftUI

public struct Banner: View {
    private let text: String
    private let tint: Color
    private let actionTitle: String
    private let isBusy: Bool
    private let action: (() -> Void)?

    public init(
        text: String,
        tint: Color = .secondary,
        actionTitle: String,
        isBusy: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.tint = tint
        self.actionTitle = actionTitle
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
    Banner(text: "8 件の詳細を取得できませんでした", actionTitle: "取り直す") {}
}

#Preview("知らせ（実行中）") {
    Banner(text: "8 件の詳細を取得できませんでした", actionTitle: "取り直す", isBusy: true) {}
}

#Preview("失敗の知らせ") {
    Banner(text: "接続を確認してください", tint: .red, actionTitle: "再取得") {}
}
