//
//  QueryableError.swift
//  
//
//  Created by Rasy on 19/7/2023.
//
import SwiftSyntax
import SwiftDiagnostics



private struct InvalidDeclarationTypeError: Error {}

private struct ErrorDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
    
    init(id: String, message: String) {
        self.message = message
        diagnosticID = MessageID(domain: "codes.hipporasy.queryable", id: id)
        severity = .error
    }
}

