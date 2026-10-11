import ScreenCore
import SwiftUI

@MainActor
struct SearchField {
    @Binding var query: String

    @FocusState private var isFocused: Bool
}

private extension SearchField {
    var isActive: Bool {
        isFocused || !query.isEmpty
    }
}

extension SearchField: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(isActive ? Color.atelierInk : Color.atelierMuted)
                .accessibilityHidden(true)

            TextField(text: $query) {
                Text(.homeSearchPrompt)
                    .foregroundStyle(Color.atelierMuted)
            }
            .font(.body)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($isFocused)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .light))
                        .frame(width: 44, height: 32)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.atelierMuted)
                .accessibilityLabel(Text(.homeClearSearch))
            }
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.atelierInk)
                .frame(height: isActive ? 1.5 : 1)
        }
        .animation(.snappy, value: isActive)
    }
}

#Preview("検索欄") {
    @Previewable @State var query = ""

    SearchField(query: $query)
        .padding(20)
        .background(Color.atelierGround)
}

#Preview("検索欄（入力あり）") {
    @Previewable @State var query = "Red"

    SearchField(query: $query)
        .padding(20)
        .background(Color.atelierGround)
}
