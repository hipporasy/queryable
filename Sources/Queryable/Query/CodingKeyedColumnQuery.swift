//
//  CodingKeyedColumnQuery.swift
//
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public protocol EntitySpecific {
    static var entityName: String { get }
}

public class CodingKeyedColumnQuery<Result, Key : CodingKey> : ColumnQuery<Result> {
    
    @discardableResult
    public func select(_ keyedColumn: Key, as alias: String) -> Self {
        return self.select(keyedColumn.stringValue, as: alias)
    }
    
    @discardableResult
    public func select(_ keyedColumns: Key...) -> Self {
        return self.select(keyedColumns.map { $0.stringValue })
    }
    
    @discardableResult
    public func select(_ keyedColumns: [Key]) -> Self {
        return self.select(keyedColumns.map { $0.stringValue } )
    }
    
    
    @discardableResult
    public func join<Q>(_ queryConvertible: Q, key: Key) -> Self where Q : ColumnQueryConvertible, Q.Result : EntitySpecific {
        return self.join(queryConvertible, as: key.stringValue, on: key.stringValue, equal: Q.Result.entityName+"id")
    }
    
    @discardableResult
    public func leftJoin<Q>(_ queryConvertible: Q, key: Key) -> Self where Q : ColumnQueryConvertible, Q.Result : EntitySpecific {
        return self.leftJoin(queryConvertible, as: key.stringValue, on: key.stringValue, equal: Q.Result.entityName+"id")
    }
    
    // MARK: Condition & Filter
    
    // This func will reset filter
    @discardableResult
    public func `where`(_ keyedCondition: CodingKeyedQueryCondition<Key>) -> Self {
        self.where(keyedCondition.condition)
        return self
    }
    
    // This func will reset filter
    @discardableResult
    public func `where`(_ keyedFilter: CodingKeyedQueryFilter<Key>) -> Self {
        self.where(keyedFilter.filter)
        return self
    }
    
    public func and(_ keyedConditions: [CodingKeyedQueryCondition<Key>]) {
        and(keyedConditions.map { $0.condition })
    }
    
    public func and(_ keyedFilters: [CodingKeyedQueryFilter<Key>]) {
        and(keyedFilters.map { $0.filter })
    }
    
    public func or(_ keyedConditions: [CodingKeyedQueryCondition<Key>]) {
        or(keyedConditions.map { $0.condition })
    }
    
    public func or(_ keyedFilters: [CodingKeyedQueryFilter<Key>]) {
        or(keyedFilters.map { $0.filter })
    }
    
    @discardableResult
    public func order(by keyedColumns: Key, descending: Bool = false) -> Self {
        self.order(Order(keyedColumns.stringValue, descending))
        return self
    }
    
    @discardableResult
    public func order(by statements: (keyedColumn: Key, descending: Bool)...) -> Self {
        self.order(statements.map { Order($0.keyedColumn.stringValue, $0.descending) })
        return self
    }
    
}

extension CodingKeyIterable where Self : EntitySpecific {

    public static func columnQuery(_ allKeys: Bool = true) -> CodingKeyedColumnQuery<Self, CodingKeys> {
        let query = CodingKeyedColumnQuery<Self, CodingKeys>(on: Self.entityName)
        if allKeys {
            query.select(CodingKeys.allCases.map { $0 })
        }
        return query
    }

    public static func columnQuerySession(_ allKeys: Bool = true, count: Int = 20, isAutoPageIncrement: Bool = true) -> QuerySession<CodingKeyedColumnQuery<Self, CodingKeys> > {
        let query = CodingKeyedColumnQuery<Self, CodingKeys>(on: Self.entityName)
        if allKeys {
            query.select(CodingKeys.allCases.map { $0.stringValue })
        }
        let _session = QuerySession(session: query, count: count, isAutoPageIncrement: isAutoPageIncrement)
        return _session
    }
    
    public static func columnQuery(excluding keyedColumns: CodingKeys...) -> CodingKeyedColumnQuery<Self, CodingKeys> {
        let columns = keyedColumns.map { $0.stringValue }
        return CodingKeyedColumnQuery<Self, CodingKeys>(on: Self.entityName)
            .select(CodingKeys.allCases.filter { !columns.contains($0.stringValue) })
    }

}


