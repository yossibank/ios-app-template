import RequiresMacroPlugin
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class RequiresMacroTests: XCTestCase {
    private let macros: [String: any Macro.Type] = ["Requires": RequiresMacro.self]

    func testGeneratesMarkerWhenAttributeIsPresent() {
        assertMacroExpansion(
            """
            @Requires("Observable")
            @Observable
            final class Model {}
            """,
            expandedSource: """
            @Observable
            final class Model {

                public static let requiredAttributes: Set<String> = ["Observable"]
            }
            """,
            macros: macros
        )
    }

    func testDiagnosesMissingAttribute() {
        assertMacroExpansion(
            """
            @Requires("Observable")
            final class Model {}
            """,
            expandedSource: """
            final class Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Observable が付いていません", line: 1, column: 1)
            ],
            macros: macros
        )
    }

    func testAcceptsQualifiedAttributeName() {
        assertMacroExpansion(
            """
            @Requires("Observable")
            @Observation.Observable
            final class Model {}
            """,
            expandedSource: """
            @Observation.Observable
            final class Model {

                public static let requiredAttributes: Set<String> = ["Observable"]
            }
            """,
            macros: macros
        )
    }

    func testDiagnosesOnlyMissingOneOfSeveral() {
        assertMacroExpansion(
            """
            @Requires("Observable", "MainActor")
            @Observable
            final class Model {}
            """,
            expandedSource: """
            @Observable
            final class Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@MainActor が付いていません", line: 1, column: 1)
            ],
            macros: macros
        )
    }

    func testDiagnosesMissingArgument() {
        assertMacroExpansion(
            """
            @Requires
            final class Model {}
            """,
            expandedSource: """
            final class Model {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Requires には検査する属性名を1つ以上渡す", line: 1, column: 1)
            ],
            macros: macros
        )
    }
}
