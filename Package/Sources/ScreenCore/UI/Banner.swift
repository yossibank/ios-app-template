import SwiftUI

public struct Banner: View {
    private let text: String
    private let style: Style
    private let accessory: Accessory

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
            Label(text, systemImage: style.symbol)
                .font(.footnote)
                .foregroundStyle(style.tint)

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

public extension Banner {
    enum Style: Sendable {
        case info
        case failure

        var tint: Color {
            switch self {
            case .info: .secondary
            case .failure: .red
            }
        }

        var symbol: String {
            switch self {
            case .info: "info.circle"
            case .failure: "exclamationmark.triangle"
            }
        }
    }

    enum Accessory {
        case none
        case progress
        case button(LocalizedStringResource, action: () -> Void)

        public static func retry(_ action: @escaping () -> Void) -> Self {
            .button(.screenRetry, action: action)
        }
    }
}

#Preview("バナー") {
    Banner(
        text: "8 件の詳細を取得できませんでした",
        accessory: .none
    )
}

#Preview("バナー(実行中)") {
    Banner(
        text: "8 件の詳細を取得できませんでした",
        accessory: .progress
    )
}

#Preview("バナー(失敗)") {
    Banner(
        text: "接続を確認してください",
        style: .failure,
        accessory: .retry {}
    )
}
