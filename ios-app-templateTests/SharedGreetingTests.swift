//
//  SharedGreetingTests.swift
//  ios-app-templateTests
//

import Testing
import Shared

/// 共通コア（kmp-app-template）が実際に呼べていることを検証する。
struct SharedGreetingTests {

    @Test func greetingComesFromSharedModule() async throws {
        let actual = Greeting().greet()
        #expect(actual.hasPrefix("Hello, iOS"), "actual: \(actual)")
    }
}
