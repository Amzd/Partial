import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PartialMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [PartialConvertibleMacro.self]
}
