//
//  CodingKeyedQueryCondition.swift
//  
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public struct CodingKeyedQueryCondition<Key: CodingKey> {
    let condition: Query.Condition
    
    fileprivate init(_ condition: Query.Condition) {
        self.condition = condition
    }
}

public prefix func ! <Key>(keyedCondition: CodingKeyedQueryCondition<Key>) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(!keyedCondition.condition)
}

public func == <Key>(lhs: Key, rhs: Operand?) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue == rhs)
}

public func != <Key>(lhs: Key, rhs: Operand?) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue != rhs)
}

public func < <Key>(lhs: Key, rhs: ComparableOperand) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue < rhs)
}

public func <= <Key>(lhs: Key, rhs: ComparableOperand) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue <= rhs)
}

public func > <Key>(lhs: Key, rhs: ComparableOperand) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue > rhs)
}

public func >= <Key>(lhs: Key, rhs: ComparableOperand) -> CodingKeyedQueryCondition<Key> where Key : CodingKey {
    return CodingKeyedQueryCondition(lhs.stringValue >= rhs)
}

extension CodingKey {
    public func like(_ pattern: String) -> CodingKeyedQueryCondition<Self> {
        return CodingKeyedQueryCondition(self.stringValue.like(pattern))
    }
    
    public func `in`(_ collection: [Operand]) -> CodingKeyedQueryCondition<Self> {
        return CodingKeyedQueryCondition(self.stringValue.in(collection))
    }
    
    public func between(_ start: ComparableOperand, and end: ComparableOperand) -> CodingKeyedQueryCondition<Self> {
        return CodingKeyedQueryCondition(self.stringValue.between(start, and: end))
    }
}
