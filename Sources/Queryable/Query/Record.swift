//
//  Record.swift
//
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public protocol RecordCovertiable {
    var record : Record { get }
}

public struct Record : RecordCovertiable {
    public let entityName : String
    public private(set) var filter : Query.Filter?
    
    public init(on entity: String, where filter: Query.Filter? = nil) {
        self.entityName = entity
        self.filter = filter
    }
    
    public init(on entity: String, where condition: Query.Condition) {
        self.entityName = entity
        self.filter = Query.Filter(logicalOperator: nil, conditions: [condition], filters: nil)
    }
    
    
    public mutating func and(_ conditions: [Query.Condition]) {
        if self.filter == nil {
            self.filter = Query.Filter(logicalOperator: .and, conditions: [], filters: nil)
        }
        self.filter!.and(conditions)
    }
    
    public mutating func and(_ filters: [Query.Filter]) {
        if self.filter == nil {
            self.filter = Query.Filter(logicalOperator: .and, conditions: nil, filters: [])
        }
        self.filter!.and(filters)
    }
    
    public mutating func or(_ conditions: [Query.Condition]) {
        if self.filter == nil {
            self.filter = Query.Filter(logicalOperator: .or, conditions: [], filters: nil)
        }
        self.filter!.or(conditions)
    }
    
    public mutating func or(_ filters: [Query.Filter]) {
        if self.filter == nil {
            self.filter = Query.Filter(logicalOperator: .or, conditions: nil, filters: [])
        }
        self.filter!.or(filters)
    }
}

extension Record {
    public var record: Record {
        return self
    }
}

