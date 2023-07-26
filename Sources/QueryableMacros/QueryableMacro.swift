import SwiftDiagnostics
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct QueryableGeneratorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EntityMacro.self,
        CodingKeyMacro.self,
        IgnoredMacro.self,
    ]
}
