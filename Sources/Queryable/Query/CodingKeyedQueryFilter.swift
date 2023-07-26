//
//  CodingKeyedQueryFilter.swift
//  
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public protocol CodingKeyed {
    associatedtype CodingKeys: CodingKey
}

public protocol CodingKeyIterable : CodingKeyed where CodingKeys: CaseIterable {}

public struct CodingKeyedQueryFilter<Key: CodingKey> {
    let filter: Query.Filter
    
    fileprivate init(_ filter: Query.Filter) {
        self.filter = filter
    }
}

public func && <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: Query.Condition) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition && rhs)
}

public func && <Key>(lhs: Query.Condition, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs && rhs.condition)
}

public func && <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition && rhs.condition)
}

public func && <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: Query.Filter) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition && rhs)
}

public func && <Key>(lhs: Query.Condition, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs && rhs.filter)
}

public func && <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition && rhs.filter)
}

public func && <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: Query.Condition) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter && rhs)
}

public func && <Key>(lhs: Query.Filter, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs && rhs.condition)
}

public func && <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter && rhs.condition)
}

public func && <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: Query.Filter) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter && rhs)
}

public func && <Key>(lhs: Query.Filter, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs && rhs.filter)
}

public func && <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter && rhs.filter)
}

public func || <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: Query.Condition) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition || rhs)
}

public func || <Key>(lhs: Query.Condition, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs || rhs.condition)
}

public func || <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition || rhs.condition)
}

public func || <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: Query.Filter) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition || rhs)
}

public func || <Key>(lhs: Query.Condition, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs || rhs.filter)
}

public func || <Key>(lhs: CodingKeyedQueryCondition<Key>, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.condition || rhs.filter)
}

public func || <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: Query.Condition) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter || rhs)
}

public func || <Key>(lhs: Query.Filter, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs || rhs.condition)
}

public func || <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter || rhs.condition)
}

public func || <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: Query.Filter) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter || rhs)
}

public func || <Key>(lhs: Query.Filter, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs || rhs.filter)
}

public func || <Key>(lhs: CodingKeyedQueryFilter<Key>, rhs: CodingKeyedQueryFilter<Key>) -> CodingKeyedQueryFilter<Key> where Key : CodingKey {
    return CodingKeyedQueryFilter(lhs.filter && rhs.filter)
}

