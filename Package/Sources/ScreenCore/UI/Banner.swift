import SwiftUI

public struct Banner: View {
    public enum Style: Sendable {
        case info
        case failure
    }

    public enum Accessory {
        case none
        case progress
        case button(LocalizedStringResource, action: () -> Void)

        public static func retry(_ action: @escaping () -> Void) -> Self {
            .button(.screenRetry, action: action)
        }
    }

    private let text: String
    private let style: Style
    private let accessory: Accessory

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
        accessory: Accessory = .none
    ) {
        self.text = text
        self.style = style
        self.accessory = accessory
    }

    public var body: some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(tint)

            Spacer()

            switch accessory {
            case .none:
                EmptyView()

            case .progress:
                ProgressView()
                    .controlSize(.small)

            case let .button(title, action):
                Button(title, action: action)
                    .font(.footnote)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview("知らせ") {
    Banner(text: "8 件の詳細を取得できませんでした", accessory: .retry {})
}

#Preview("知らせ（実行中）") {
    Banner(text: "8 件の詳細を取得できませんでした", accessory: .progress)
}

#Preview("失敗の知らせ") {
    Banner(text: "接続を確認してください", style: .failure, accessory: .retry {})
}
