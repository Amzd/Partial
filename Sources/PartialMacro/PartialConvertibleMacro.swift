import SwiftSyntax
import SwiftSyntaxMacros
import MacroToolkit

enum PartialConvertibleMacro: ExtensionMacro {
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        let properties = DeclGroup(declaration).properties.map(\.identifier)

        return [try ExtensionDeclSyntax("""
        extension \(type.trimmed): PartialConvertible {
            init(partial: Partial<Self>) throws {
                \(raw: properties.map { "self.\($0) = try partial.value(for: \\.\($0))" }.joined(separator: "\n"))
            }
            func partial() -> Partial<Self> {
                var partial = Partial<Self>()
                \(raw: properties.map { "partial.\($0) = \($0)" }.joined(separator: "\n"))
                return partial
            }
        }
        """)]
    }
}
