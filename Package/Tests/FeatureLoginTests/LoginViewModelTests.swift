@testable import FeatureLogin
import ScreenCore
import SharedCore
import Testing

@MainActor
struct LoginViewModelTests {
    @Test("ログインできたらログイン済みになる")
    func loggingInSucceeds() async {
        let authenticator = StubAuthenticator(.loggedIn)
        let model = makeModel(authenticator)
        let expected = [Attempt(username: "emilys", password: "emilyspass")]

        model.username = " emilys "
        model.password = "emilyspass"
        await model.submit()

        #expect(model.isLoggedIn)
        #expect(authenticator.attempts == expected)
    }

    @Test("拒否されたら理由を出し、ログイン済みにはしない")
    func rejectionShowsTheReason() async {
        let authenticator = StubAuthenticator(.rejected)
        let model = makeModel(authenticator)

        await model.submit()

        #expect(!model.isLoggedIn)
        #expect(model.failure?.message == "ユーザー名かパスワードが違います")
        #expect(!model.isSubmitting)
    }

    @Test("通信できなかったら共通の文言で知らせる")
    func networkFailuresUseTheSharedMessage() async {
        let authenticator = StubAuthenticator(.failed(.offline))
        let model = makeModel(authenticator)

        await model.submit()

        #expect(model.failure == .offline)
    }

    @Test("入力を直したら前の失敗は消える")
    func editingClearsTheFailure() async {
        let authenticator = StubAuthenticator(.rejected)
        let model = makeModel(authenticator)
        await model.submit()

        model.password = "other"

        #expect(model.failure == nil)
    }

    @Test("ユーザー名が空なら送らない")
    func blankUsernameIsNotSent() async {
        let authenticator = StubAuthenticator(.loggedIn)
        let model = makeModel(authenticator)

        model.username = "  "
        await model.submit()

        #expect(authenticator.attempts.isEmpty)
    }
}

extension LoginViewModelTests {
    struct Attempt: Equatable {
        let username: String
        let password: String
    }

    final class StubAuthenticator: @unchecked Sendable {
        private(set) var attempts: [Attempt] = []

        private let outcome: LoginOutcome

        init(_ outcome: LoginOutcome) {
            self.outcome = outcome
        }
    }
}

private extension LoginViewModelTests {
    func makeModel(_ authenticator: StubAuthenticator) -> LoginViewModel {
        let dependency = LoginViewModel.Dependency(authenticator: authenticator)
        return LoginViewModel(dependency: dependency)
    }
}

extension LoginViewModelTests.StubAuthenticator: Authenticating {
    func login(
        username: String,
        password: String
    ) async -> LoginOutcome {
        let attempt = LoginViewModelTests.Attempt(username: username, password: password)
        attempts.append(attempt)
        return outcome
    }
}
