import ScreenCore
import Shared
@testable import SharedCore
import Testing

struct LoginOutcomeTests {
    @Test("ログインの結果がそのまま画面向けの結果になる")
    func resultsBecomeOutcomes() {
        #expect(LoginOutcome(LoginResultLoggedIn.shared) == .loggedIn)
        #expect(LoginOutcome(LoginResultRejected.shared) == .rejected)
    }

    @Test("通信の失敗は共通の文言を連れてくる")
    func failuresCarryTheSharedMessage() {
        #expect(LoginOutcome(LoginResultFailed(failure: ApiFailureOffline.shared)) ==
            .failed(.offline))
    }
}
