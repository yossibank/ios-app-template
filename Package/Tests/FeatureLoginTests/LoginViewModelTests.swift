@testable import FeatureLogin
import ScreenCore
import SharedCore
import Testing

@MainActor
struct LoginViewModelTests {
    @Test("ログインできたらログイン済みになる")
    func loggingInSucceeds() async {
        let authenticator = StubAuthenticator(.loggedIn)
        let model = LoginViewModel(dependency: .init(authenticator: authenticator))

        model.username = " emilys "
        model.password = "emilyspass"
        await model.submit()

        #expect(model.isLoggedIn)
        #expect(authenticator.attempts == [Attempt(username: "emilys", password: "emilyspass")])
    }

    @Test("拒否されたら理由を出し、ログイン済みにはしない")
    func rejectionShowsTheReason() async {
        let model = LoginViewModel(dependency: .init(authenticator: StubAuthenticator(.rejected)))

        await model.submit()

        #expect(!model.isLoggedIn)
        #expect(model.failure?.message == "ユーザー名かパスワードが違います")
        #expect(!model.isSubmitting)
    }

    @Test("通信できなかったら共通の文言で知らせる")
    func networkFailuresUseTheSharedMessage() async {
        let model =
            LoginViewModel(dependency: .init(authenticator: StubAuthenticator(.failed(.offline))))

        await model.submit()

        #expect(model.failure == .offline)
    }

    @Test("入力を直したら前の失敗は消える")
    func editingClearsTheFailure() async {
        let model = LoginViewModel(dependency: .init(authenticator: StubAuthenticator(.rejected)))
        await model.submit()

        model.password = "other"

        #expect(model.failure == nil)
    }

    @Test("ユーザー名が空なら送らない")
    func blankUsernameIsNotSent() async {
        let authenticator = StubAuthenticator(.loggedIn)
        let model = LoginViewModel(dependency: .init(authenticator: authenticator))

        model.username = "  "
        await model.submit()

        #expect(authenticator.attempts.isEmpty)
    }
}

private struct Attempt: Equatable {
    let username: String
    let password: String
}

private final class StubAuthenticator: Authenticating, @unchecked Sendable {
    private(set) var attempts: [Attempt] = []

    private let outcome: LoginOutcome

    init(_ outcome: LoginOutcome) {
        self.outcome = outcome
    }

    func login(username: String, password: String) async -> LoginOutcome {
        attempts.append(Attempt(username: username, password: password))
        return outcome
    }
}
