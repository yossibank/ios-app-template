import SwiftUI

public struct BannerView: View {
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
        HStack(spacing: 16) {
            Label(text, systemImage: style.symbol)
                .font(.footnote)
                .foregroundStyle(style.tint)

            switch accessory {
            case .none:
                EmptyView()

            case .progress:
                ProgressView()
                    .controlSize(.small)

            case let .button(title, action):
                outlinedButton(title, action: action)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private extension BannerView {
    func outlinedButton(
        _ title: LocalizedStringResource,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .overlay {
                    Capsule()
                        .stroke(.quaternary, lineWidth: 1)
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}

public extension BannerView {
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
    BannerView(
        text: "8 件の詳細を取得できませんでした",
        accessory: .none
    )
}

#Preview("バナー(実行中)") {
    BannerView(
        text: "8 件の詳細を取得できませんでした",
        accessory: .progress
    )
}

#Preview("バナー(失敗)") {
    BannerView(
        text: "接続を確認してください",
        style: .failure,
        accessory: .retry {}
    )
}
