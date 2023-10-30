//
//  AttributeSyntax.swift
//
//
//  Created by Rasy on 10/7/2023.
//
import SwiftSyntax

extension AttributeSyntax {
    var firstArgument: String? {
        if case let .argumentList(list) = arguments {
            return list.first?.expression.description.withoutQuotes
        }

        return nil
    }
}


extension String {
    var withoutQuotes: String {
        filter { $0 != "\"" }
    }
}
