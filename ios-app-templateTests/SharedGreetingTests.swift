import Shared
import Testing

/// 共通コア（kmp-app-template）が実際に呼べていることを検証する。
struct SharedGreetingTests {
    @Test func greetingComesFromSharedModule() {
        let actual = Greeting().greet()
        #expect(actual.hasPrefix("Hello, iOS"), "actual: \(actual)")
    }
}
