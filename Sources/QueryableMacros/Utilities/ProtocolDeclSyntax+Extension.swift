//
//  ProtocolDeclSyntax+Extension.swift
//
//
//  Created by Rasy on 10/7/2023.
//

import Foundation
import SwiftSyntax

extension ProtocolDeclSyntax {
    
    var typeName: String {
        identifier.text
    }
    
    var access: String {
        modifiers?.first.map { "\($0.trimmedDescription) " } ?? ""
    }

    var functions: [FunctionDeclSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
    
}
