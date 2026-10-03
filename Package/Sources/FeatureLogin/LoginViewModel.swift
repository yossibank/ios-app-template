import Foundation
import Observation
import ScreenCore
import SharedCore

@MainActor
@Observable
final class LoginViewModel {
    var username = "emilys" {
        didSet { failure = nil }
    }

    var password = "emilyspass" {
        didSet { failure = nil }
    }

    private(set) var isSubmitting = false
    private(set) var failure: FetchFailure?
    private(set) var isLoggedIn = false

    let dependency: Dependency

    var canSubmit: Bool {
        !trimmedUsername.isEmpty && !password.isEmpty && !isSubmitting
    }

    convenience init() {
        self.init(dependency: .init())
    }

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func submit() async {
        guard canSubmit else {
            return
        }

        isSubmitting = true
        failure = nil

        let outcome = await dependency.authenticator.login(
            username: trimmedUsername,
            password: password
        )

        isSubmitting = false

        switch outcome {
        case .loggedIn:
            isLoggedIn = true

        case .rejected:
            failure = FetchFailure(.loginRejected, canRetry: false)

        case let .failed(failure):
            self.failure = failure
        }
    }
}

private extension LoginViewModel {
    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension LoginViewModel {
    struct Dependency {
        var authenticator: any Authenticating = SessionAuthenticator()
    }
}
