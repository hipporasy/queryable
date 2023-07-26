//
//  Query.swift
//
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public class Query {
    
    private(set) var record: Record
    
    var entityName: String {
        return record.entityName
    }
    
    var filter: Filter? {
        return record.filter
    }
    
    public convenience init(on entity: String, where filter: Filter? = nil) {
        self.init(record: .init(on: entity, where: filter))
    }
    
    public convenience init(on entity: String, where condition: Condition) {
        self.init(record: .init(on: entity, where: condition))
    }
    
    init(record: Record) {
        self.record = record
    }
    
    // This func will reset filter
    @discardableResult
    public func `where`(_ condition: Condition) -> Self {
        record = Record(on: record.entityName, where: condition)
        return self
    }
    
    // This func will reset filter
    @discardableResult
    public func `where`(_ filter: Filter) -> Self {
        record = Record(on: record.entityName, where: filter)
        return self
    }
    
    public func and(_ conditions: [Condition]) {
        record.and(conditions)
    }
    
    public func and(_ filters: [Filter]) {
        record.and(filters)
    }
    
    public func or(_ conditions: [Condition]) {
        record.or(conditions)
    }
    
    public func or(_ filters: [Filter]) {
        record.or(filters)
    }
}

extension Query {
    public typealias Order = (key: String, descending: Bool)
}


public protocol Operand {}
public protocol ComparableOperand : Operand {}

extension UUID : Operand {}
extension String : ComparableOperand {}
extension Bool : Operand {}
extension Int : ComparableOperand {}
extension Double : ComparableOperand {}
extension Decimal : ComparableOperand {}
extension Date : ComparableOperand {} // considered as Date-Only

extension Query {
    public struct Condition {
        
        let attribute : String
        let `operator` : (negated: Bool, Operator)
        
        public init(_ attribute: String,_ opt: Operator) {
            self.attribute = attribute
            self.operator = (negated: false, opt)
        }
        
        init(_ attribute: String, not opt: Operator) {
            self.attribute = attribute
            self.operator = (negated: true, opt)
        }
        
        public enum Operator {
            
            case equal(Operand)
            case lessThan(ComparableOperand)
            case lessThanOrEqual(ComparableOperand)
            case greaterThan(ComparableOperand)
            case greaterThanOrEqual(ComparableOperand)
            case like(String)
            case `in`([Operand])
            case between(ComparableOperand, ComparableOperand)
            case isNull
            
        }
    }
}

public prefix func ! (condition: Query.Condition) -> Query.Condition {
    if condition.operator.negated {
        return Query.Condition(condition.attribute, condition.operator.1)
    } else {
        return Query.Condition(condition.attribute, not: condition.operator.1)
    }
}

public func == (lhs: String, rhs: Operand?) -> Query.Condition {
    if let operand = rhs {
        return Query.Condition(lhs, .equal(operand))
    } else {
        return Query.Condition(lhs, .isNull)
    }
}

public func != (lhs: String, rhs: Operand?) -> Query.Condition {
    if let operand = rhs {
        return Query.Condition(lhs, not: .equal(operand))
    } else {
        return Query.Condition(lhs, not: .isNull)
    }
}

public func < (lhs: String, rhs: ComparableOperand) -> Query.Condition {
    return Query.Condition(lhs, .lessThan(rhs))
}

public func <= (lhs: String, rhs: ComparableOperand) -> Query.Condition {
    return Query.Condition(lhs, .lessThanOrEqual(rhs))
}

public func > (lhs: String, rhs: ComparableOperand) -> Query.Condition {
    return Query.Condition(lhs, .greaterThan(rhs))
}

public func >= (lhs: String, rhs: ComparableOperand) -> Query.Condition {
    return Query.Condition(lhs, .greaterThanOrEqual(rhs))
}

extension String {
    public func like(_ pattern: String) -> Query.Condition {
        return Query.Condition(self, .like(pattern))
    }
    
    public func `in`(_ collection: [Operand]) -> Query.Condition {
        return Query.Condition(self, .in(collection))
    }
    
    public func between(_ start: ComparableOperand, and end: ComparableOperand) -> Query.Condition {
        return Query.Condition(self, .between(start, end))
    }
}


extension Query {
    public struct Filter {
        
        // logicalOperator must not be changed from 'and' to 'or' or vice versa
        // nil means it can be set later. For example, a filter with a single condition
        
        public private(set) var logicalOperator: LogicalOperator!
        public private(set) var conditions: [Condition]?
        public private(set) var filters: [Filter]?
        
        public enum LogicalOperator {
            case and
            case or
        }
        
        public init(logicalOperator: LogicalOperator?, conditions: [Condition]?, filters: [Filter]?) {
            self.logicalOperator = logicalOperator
            self.conditions = conditions
            self.filters = filters
        }
        
        public mutating func and(_ conditions: [Condition]) {
            // nil logicalOperator will pass and to be set below
            guard self.logicalOperator != .or else { return }
            
            self.logicalOperator = .and
            self.addConditions(conditions)
        }
        
        public mutating func or(_ conditions: [Condition]) {
            guard self.logicalOperator != .and else { return }
            
            self.logicalOperator = .or
            self.addConditions(conditions)
        }
        
        public mutating func and(_ filters: [Filter]) {
            guard self.logicalOperator != .or else { return }
            
            self.logicalOperator = .and
            self.addFilters(filters)
        }
        
        public mutating func or(_ filters: [Filter]) {
            guard self.logicalOperator != .and else { return }
            
            self.logicalOperator = .or
            self.addFilters(filters)
        }
        
        private mutating func addConditions(_ conditions: [Condition]) {
            if self.conditions == nil {
                self.conditions = []
            }
            self.conditions!.append(contentsOf: conditions)
        }
        
        private mutating func addFilters(_ filters: [Filter]) {
            if self.filters == nil {
                self.filters = []
            }
            self.filters!.append(contentsOf: filters)
        }
    }
}

public prefix func ! (filter: Query.Filter) -> Query.Filter {
    return Query.Filter(logicalOperator: filter.logicalOperator == .or ? .and : .or,
                  conditions: filter.conditions,
                  filters: filter.filters)
}

public func && (lhs: Query.Condition, rhs: Query.Condition) -> Query.Filter {
    return Query.Filter(logicalOperator: .and, conditions: [lhs,rhs], filters: nil)
}

public func && (lhs: Query.Condition, rhs: Query.Filter) -> Query.Filter {
    if rhs.logicalOperator == .and {
        var filter = rhs
        filter.and([lhs])
        return filter
    } else {
        return Query.Filter(logicalOperator: .and, conditions: [lhs], filters: [rhs])
    }
}

public func && (lhs: Query.Filter, rhs: Query.Condition) -> Query.Filter {
    if lhs.logicalOperator == .and {
        var filter = lhs
        filter.and([rhs])
        return filter
    } else {
        return Query.Filter(logicalOperator: .and, conditions: [rhs], filters: [lhs])
    }
}

public func && (lhs: Query.Filter, rhs: Query.Filter) -> Query.Filter {
    return Query.Filter(logicalOperator: .and, conditions: nil, filters: [lhs, rhs])
}

public func || (lhs: Query.Condition, rhs: Query.Condition) -> Query.Filter {
    return Query.Filter(logicalOperator: .or, conditions: [lhs,rhs], filters: nil)
}

public func || (lhs: Query.Condition, rhs: Query.Filter) -> Query.Filter {
    if rhs.logicalOperator == .or {
        var filter = rhs
        filter.or([lhs])
        return filter
    } else {
        return Query.Filter(logicalOperator: .or, conditions: [lhs], filters: [rhs])
    }
}

public func || (lhs: Query.Filter, rhs: Query.Condition) -> Query.Filter {
    if lhs.logicalOperator == .or {
        var filter = lhs
        filter.or([rhs])
        return filter
    } else {
        return Query.Filter(logicalOperator: .or, conditions: [rhs], filters: [lhs])
    }
}

public func || (lhs: Query.Filter, rhs: Query.Filter) -> Query.Filter {
    return Query.Filter(logicalOperator: .or, conditions: nil, filters: [lhs, rhs])
}

extension Query.Filter {
    var refined: Query.Filter {
        
        // No child fitlers, this filter is refined
        guard let filters = self.filters, !filters.isEmpty else {
            return self
        }
        
        let refinedChildren = filters.map { $0.refined }
        
        // No conditions, and only one child filter, replace this filter with that one child filter
        if (self.conditions == nil || self.conditions!.isEmpty ) && refinedChildren.count == 1 {
            return refinedChildren.first!
        }
        
        var refinedFilter = Query.Filter(logicalOperator: logicalOperator,
                                   conditions: conditions!,
                                   filters: nil)
        
        refinedChildren.forEach { eachRefinedChild in
            // logical operator can not be nil
            if eachRefinedChild.logicalOperator != logicalOperator {
                refinedFilter.addFilters([eachRefinedChild])
            } else {
                refinedFilter.addConditions(eachRefinedChild.conditions ?? [])
                refinedFilter.addFilters(eachRefinedChild.filters ?? [])
            }
        }
        
        return refinedFilter
    }
}

extension Query {
    struct Join<T> {
        
        let type: JoinType
        let joinedQuery: T
        let rightAlias: String?
        
        let leftColumn: String
        let rightColumn: String
    }

    enum JoinType {
        case inner
        case leftOuter
    }
}
