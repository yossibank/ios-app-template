import SwiftUI

struct Banner: View {
    let text: String

    var color: Color = .secondary
    var action: String = HomeStrings.reload
    var busy = false

    var retry: (() -> Void)?

    var body: some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(color)

            Spacer()

            if busy {
                ProgressView()
                    .controlSize(.small)
            } else if let retry {
                Button(action, action: retry)
                    .font(.footnote)
            }
        }
        .padding(.horizontal, 4)
    }
}
