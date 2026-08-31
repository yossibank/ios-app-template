import Core
import Testing

/// 共通コア（kmp-app-template）が Core 経由で呼べていることを検証する。
struct SharedGreetingTests {
    @Test func greetingComesFromSharedModule() {
        let actual = Greeting().greet()
        #expect(actual.hasPrefix("Hello, iOS"), "actual: \(actual)")
    }
}
