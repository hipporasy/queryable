//
//  String+Extension.swift
//  
//
//  Created by Rasy on 19/7/2023.
//

import Foundation

extension String {

    func snakeCased() -> String {
        reduce(into: "") { $0.append(contentsOf: $1.isUppercase ? "_\($1.lowercased())" : "\($1)") }
    }
    
}
