import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct MissingAttribute: DiagnosticMessage {
    let attribute: String

    var message: String {
        "@\(attribute) が付いていません"
    }

    var diagnosticID: MessageID {
        MessageID(domain: "RequiresMacro", id: "missingAttribute.\(attribute)")
    }

    let severity = DiagnosticSeverity.error
}

struct MissingArgument: DiagnosticMessage {
    let message = "@Requires には検査する属性名を1つ以上渡す"
    let diagnosticID = MessageID(domain: "RequiresMacro", id: "missingArgument")
    let severity = DiagnosticSeverity.error
}

public struct RequiresMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let required = requiredAttributes(of: node)

        guard !required.isEmpty else {
            context.diagnose(Diagnostic(node: node, message: MissingArgument()))
            return []
        }

        let present = attachedAttributes(of: declaration)
        let missing = required.filter { !present.contains($0) }

        guard missing.isEmpty else {
            for attribute in missing {
                context.diagnose(
                    Diagnostic(node: node, message: MissingAttribute(attribute: attribute))
                )
            }
            return []
        }

        let literals = required.sorted().map { "\"\($0)\"" }.joined(separator: ", ")
        return ["public static let requiredAttributes: Set<String> = [\(raw: literals)]"]
    }

    static func requiredAttributes(of node: AttributeSyntax) -> [String] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }

        return arguments.compactMap { argument in
            argument.expression
                .as(StringLiteralExprSyntax.self)?
                .representedLiteralValue
        }
    }

    static func attachedAttributes(of declaration: some DeclGroupSyntax) -> Set<String> {
        Set(
            declaration.attributes.compactMap { element in
                guard case let .attribute(attribute) = element else {
                    return nil
                }

                let name = attribute.attributeName.trimmedDescription
                return name.split(separator: ".").last.map(String.init) ?? name
            }
        )
    }
}

@main
struct RequiresMacroPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [RequiresMacro.self]
}
