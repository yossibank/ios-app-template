import SwiftUI

public struct BannerView: View {
    private let text: String
    private let accessory: Accessory

    public init(
        text: String,
        accessory: Accessory = .none
    ) {
        self.text = text
        self.accessory = accessory
    }

    public var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)

            switch accessory {
            case .none:
                EmptyView()

            case .progress:
                ProgressView()
                    .tint(Color.atelierGround)
                    .frame(minWidth: 44, minHeight: 44)

            case let .button(title, action):
                Button(action: action) {
                    Text(title)
                }
                .buttonStyle(
                    AtelierOutlineButtonStyle(
                        color: .atelierGround,
                        horizontalPadding: 16,
                        minHeight: 44
                    )
                )
            }
        }
        .foregroundStyle(Color.atelierGround)
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.atelierInk)
        .accessibilityElement(children: .contain)
    }
}

public extension BannerView {
    enum Accessory {
        case none
        case progress
        case button(LocalizedStringResource, action: () -> Void)

        public static func retry(_ action: @escaping () -> Void) -> Self {
            .button(.screenRetry, action: action)
        }
    }
}

#Preview("バナー（失敗）") {
    BannerView(
        text: "続きを読み込めませんでした。接続を確認してください",
        accessory: .retry {}
    )
    .padding()
}

#Preview("バナー（実行中）") {
    BannerView(
        text: "続きを読み込めませんでした。接続を確認してください",
        accessory: .progress
    )
    .padding()
}
