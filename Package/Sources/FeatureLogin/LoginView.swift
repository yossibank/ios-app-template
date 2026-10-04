import ScreenCore
import SwiftUI

public struct LoginView: View {
    @State private var model: LoginViewModel
    @State private var showsPassword = false

    @FocusState private var focus: Field?

    private let onLoggedIn: () -> Void

    init(model: LoginViewModel, onLoggedIn: @escaping () -> Void = {}) {
        _model = State(initialValue: model)
        self.onLoggedIn = onLoggedIn
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 56) {
                heading

                VStack(alignment: .leading, spacing: 32) {
                    usernameField
                    passwordField

                    if let failure = model.failure {
                        Text(failure.message)
                            .font(.footnote)
                            .foregroundStyle(Color.atelierError)
                    }

                    submitButton
                        .padding(.top, 16)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 96)
            .padding(.bottom, 48)
        }
        .scrollDismissesKeyboard(.interactively)
        .foregroundStyle(Color.atelierInk)
        .background(Color.atelierGround)
        .onChange(of: model.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                onLoggedIn()
            }
        }
    }
}

public extension LoginView {
    init(onLoggedIn: @escaping () -> Void) {
        self.init(model: LoginViewModel(), onLoggedIn: onLoggedIn)
    }
}

private extension LoginView {
    enum Field {
        case username
        case password
    }

    var heading: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(.loginCollection)
                .font(.atelierSerif(40, relativeTo: .largeTitle, italic: true))

            Rectangle()
                .fill(Color.atelierInk)
                .frame(width: 32, height: 1)

            Text(.loginTitle)
                .font(.atelierMincho(22, relativeTo: .title2, bold: true))
                .tracking(1.8)
                .accessibilityAddTraits(.isHeader)
        }
    }

    var usernameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            label(.loginUsername)

            TextField(text: $model.username) {
                Text(.loginUsername)
            }
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focus, equals: .username)
            .onSubmit {
                focus = .password
            }
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                underline(isActive: focus == .username)
            }
        }
    }

    var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            label(.loginPassword)

            HStack(spacing: 0) {
                Group {
                    if showsPassword {
                        TextField(text: $model.password) {
                            Text(.loginPassword)
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    } else {
                        SecureField(text: $model.password) {
                            Text(.loginPassword)
                        }
                    }
                }
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focus, equals: .password)
                .onSubmit(submit)

                Button {
                    showsPassword.toggle()
                } label: {
                    Image(systemName: showsPassword ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .light))
                        .frame(width: 44, height: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.atelierMuted)
                .accessibilityLabel(Text(showsPassword ? .loginHidePassword : .loginShowPassword))
            }
            .overlay(alignment: .bottom) {
                underline(isActive: focus == .password)
            }
        }
    }

    var submitButton: some View {
        Button(action: submit) {
            Group {
                if model.isSubmitting {
                    ProgressView()
                        .tint(Color.atelierGround)
                } else {
                    Text(.loginSubmit)
                        .font(.atelierMincho(15, relativeTo: .body, bold: true))
                        .tracking(3.6)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Color.atelierGround)
            .background(Color.atelierInk.opacity(model.canSubmit || model.isSubmitting ? 1 : 0.35))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!model.canSubmit)
    }

    func label(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.caption2)
            .tracking(2)
            .foregroundStyle(Color.atelierMuted)
            .accessibilityHidden(true)
    }

    func underline(isActive: Bool) -> some View {
        Rectangle()
            .fill(Color.atelierInk)
            .frame(height: isActive ? 1.5 : 1)
    }

    func submit() {
        focus = nil

        Task {
            await model.submit()
        }
    }
}

#Preview("入力") {
    LoginView(model: LoginViewModel())
}

#Preview("入力（ダーク）") {
    LoginView(model: LoginViewModel())
        .preferredColorScheme(.dark)
}
