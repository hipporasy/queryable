//
//  DeclGroupSyntax+Extension.swift
//
//
//  Created by Rasy on 19/7/2023.
//

import Foundation
import SwiftSyntax

private struct TypedVariable {
    let name: String
    let type: String
}

extension DeclGroupSyntax {
    /// Declaration name
    /// example: struct User will return "User"
    var name: String? {
        asProtocol(IdentifiedDeclSyntax.self)?.identifier.text
    }
    
    fileprivate var typedMembers: [TypedVariable] {
        storedVariables.compactMap { property -> TypedVariable? in
            guard let name = property.name,
                  let type = property.typeString else {
                return nil
            }
            return TypedVariable(
                name: name,
                type: type
            )
        }
    }
    
    var storedVariables: [VariableDeclSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter(\.isStoredProperty)
    }
    
    var isStruct: Bool {
        self.as(StructDeclSyntax.self) != nil
    }
    
    var isClass: Bool {
        self.as(ClassDeclSyntax.self) != nil
    }
}

extension [TypedVariable] {
    
    var publicVariables: String {
        map(\.publicOptionalVarDefinition)
            .joined(separator: "\n")
    }
    
    var fillAssignments: String {
        map { $0.assignment(from: "item", isOptional: true) }
            .joined(separator: "\n")
    }
    
    var buildGuards: String {
        "guard " + self
            .filter { !$0.isOptional }
            .compactMap(\.guardCheck)
            .joined(separator: ", ")
    }
    
    var initAssignments: String {
        map(\.initAssignment)
            .joined(separator: ",\n")
    }
    
}

extension TypedVariable {
    
    func assignment(
        from property: String,
        isOptional: Bool
    ) -> String {
        "\(name) = \(property + (isOptional ? "?" : "")).\(name)"
    }
    
    var initAssignment: String {
        isUUID
        ? "\(name): \(name) ?? UUID()"
        : "\(name): \(name)"
    }
    
    var publicOptionalVarDefinition: String {
        "public var \(name): \(optionalType)"
    }
    
    var guardCheck: String? {
        return isUUID
        ? nil
        : "let \(name)"
    }
    
    var isUUID: Bool { name == "uuid" }
    var isOptional: Bool { type.last == "?" }
    
    private var optionalType: String {
        isOptional ? type : "\(type)?"
    }
    
}
