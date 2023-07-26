//
//  EntityMacro.swift
//
//
//  Created by Rasy on 19/7/2023.
//
import SwiftDiagnostics
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EntityMacro {
    
    private enum MacroIdentity: String {
        case ignore = "Ignore"
        case codingKey = "CodingKey"
    }
    
}

extension EntityMacro: ExtensionMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        guard declaration.isStruct || declaration.isClass else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: QueryableDiagnostic.mustBeClassOrStruct)
            )
            return []
        }
        
        guard !declaration.memberBlock.members.isEmpty else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: QueryableDiagnostic.mustHaveMember)
            )
            return []
        }
        
        let syntax: DeclSyntax = """
        extension \(raw: declaration.name!): \(raw: "EntitySpecific"), CodingKeyIterable, Decodable {
            static var entityName: String {
                \(literal: declaration.name ?? "")
            }
        }
        """
        
        return [syntax.cast(ExtensionDeclSyntax.self)]
    }
    
}

extension EntityMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        var cases: [String] = []
        var initResult: [String] = []
        for member in declaration.memberBlock.members {
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            
            guard let property = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                continue
            }
            
            if attributesElement(withIdentifier: MacroIdentity.ignore.rawValue, in: variableDecl.attributes) != nil {
                initResult.append("\(property) = nil")
                continue
            }
            if let element = attributesElement(withIdentifier: MacroIdentity.codingKey.rawValue, in: variableDecl.attributes) {
                guard let customKeyName = customKey(in: element) else {
                    let diagnostic = Diagnostic(node: Syntax(node), message: QueryableDiagnostic.mustBeClassOrStruct)
                    throw DiagnosticsError(diagnostics: [diagnostic])
                }
                cases.append("case \(property) = \(customKeyName)")
            } else {
                cases.append("case \(property) = \"\(property.snakeCased())\"")
                
            }
            initResult.append(buildDecode(property: property, type: variableDecl.unwrapTypeString!, isOptional: variableDecl.isOptional))
        }
        let casesDecl: DeclSyntax = """
enum CodingKeys: String, CodingKey, CaseIterable {
    \(raw: cases.joined(separator: "\n    "))
}
"""
        let initDecl: DeclSyntax = """
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    \(raw: initResult.joined(separator: "\n    "))
}
"""
        return [casesDecl, initDecl]
    }
    
    private static func attributesElement(
        withIdentifier macroName: String,
        in attributes: AttributeListSyntax?
    ) -> AttributeListSyntax.Element? {
        attributes?.first {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(SimpleTypeIdentifierSyntax.self)?
                .description == macroName
        }
    }
    
    private static func customKey(in attributesElement: AttributeListSyntax.Element) -> ExprSyntax? {
        attributesElement
            .as(AttributeSyntax.self)?
            .argument?
            .as(TupleExprElementListSyntax.self)?
            .first?
            .expression
    }
}

public struct CodingKeyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct IgnoredMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

enum QueryableDiagnostic: String, DiagnosticMessage {
    case mustBeClassOrStruct
    case mustHaveMember
    
    var severity: DiagnosticSeverity {
        return .error
    }
    
    var message: String {
        switch self {
        case .mustBeClassOrStruct:
            return "`@Entity` can only applied to a `struct` or `class`"
        case .mustHaveMember:
            return "`@Entity` must contains members or properties"
        }
    }
    var  diagnosticID: MessageID {
        .init(domain: "codes.hipporasy", id: rawValue)
    }
}

private func buildDecode(property: String, type: String, isOptional: Bool) -> String {
    
    if isOptional {
        return "\(property) = try container.decodeIfPresent(\(type).self, forKey: .\(property))"
    }
    return "\(property) = try container.decode(\(type).self, forKey: .\(property))"
}

