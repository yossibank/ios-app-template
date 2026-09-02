import Core
import Testing

struct SharedGreetingTests {
    @Test func greetingComesFromSharedModule() {
        let actual = Greeting().greet()
        #expect(actual.hasPrefix("Hello, iOS"), "actual: \(actual)")
    }
}
