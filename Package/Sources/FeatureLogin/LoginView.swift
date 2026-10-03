import ScreenCore
import SwiftUI

public struct LoginView: View {
    @State private var model: LoginViewModel

    private let onLoggedIn: () -> Void

    init(model: LoginViewModel, onLoggedIn: @escaping () -> Void = {}) {
        _model = State(initialValue: model)
        self.onLoggedIn = onLoggedIn
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(text: $model.username) {
                        Text(.loginUsername)
                    }
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    SecureField(text: $model.password) {
                        Text(.loginPassword)
                    }
                    .textContentType(.password)
                    .onSubmit(submit)
                } footer: {
                    if let failure = model.failure {
                        Text(failure.message)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(action: submit) {
                        Group {
                            if model.isSubmitting {
                                ProgressView()
                            } else {
                                Text(.loginSubmit)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!model.canSubmit)
                }
            }
            .navigationTitle(.loginTitle)
        }
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
    func submit() {
        Task {
            await model.submit()
        }
    }
}

#Preview("入力") {
    LoginView(model: LoginViewModel())
}
