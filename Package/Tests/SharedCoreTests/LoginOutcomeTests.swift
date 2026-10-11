import ScreenCore
import Shared
@testable import SharedCore
import Testing

struct LoginOutcomeTests {
    @Test("ログインの結果がそのまま画面向けの結果になる")
    func resultsBecomeOutcomes() {
        let loggedIn = LoginOutcome(LoginResultLoggedIn.shared)
        let rejected = LoginOutcome(LoginResultRejected.shared)

        #expect(loggedIn == .loggedIn)
        #expect(rejected == .rejected)
    }

    @Test("通信の失敗は共通の文言を連れてくる")
    func failuresCarryTheSharedMessage() {
        let result = LoginResultFailed(failure: ApiFailureOffline.shared)
        let outcome = LoginOutcome(result)
        #expect(outcome == .failed(.offline))
    }
}
