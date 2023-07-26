//
//  File.swift
//  
//
//  Created by Rasy on 10/7/2023.
//

import Foundation

public struct ColumnAttribute {
    public let name : String
    public let alias : String?
    
    public init(name: String, alias: String? = nil) {
        self.name = name
        self.alias = alias
    }
}

internal enum ColumnQuerySelect {
    case all
    case some([ColumnAttribute])
}

public protocol ColumnQueryConvertible : SessionQuery {

    var query: ColumnQuery<Result> { get }
}

public class ColumnQuery<Result> : Query, ColumnQueryConvertible {
    
    private(set) var select : ColumnQuerySelect = .some([])
    
    private func _append(_ columns: [ColumnAttribute]) {
        var columnAttributes = columns
        if case .some(let existingColumns) = select {
            columnAttributes.append(contentsOf: existingColumns)
        }
        select = .some(columnAttributes)
    }
    
    internal convenience init<T>(other: ColumnQuery<T>) {
        self.init(record: other.record)
        self.select = other.select
        self.columnQueryJoins = other.columnQueryJoins.map {
            return Join(type: $0.type, joinedQuery: ColumnQuery(other: $0.joinedQuery),
                        rightAlias: $0.rightAlias, leftColumn: $0.leftColumn, rightColumn: $0.rightColumn)
        }
//        self.neutJoins = other.neutJoins.map {
//            return Join(type: $0.type, joinedQuery: NeutQuery(other: $0.joinedQuery),
//                        rightAlias: $0.rightAlias, leftColumn: $0.leftColumn, rightColumn: $0.rightColumn)
//        }
        self.orderedColumns = other.orderedColumns
    }
    
    @discardableResult
    public func selectAll() -> Self {
        select = .all
        return self
    }
    
    @discardableResult
    public func select(_ column: String, as alias: String) -> Self {
        _append([.init(name: column, alias: alias)])
        return self
    }
    
    @discardableResult
    public func select(_ columns: String...) -> Self {
        _append(columns.map { .init(name: $0, alias: nil) })
        return self
    }
    
    @discardableResult
    public func select(_ columns: [String]) -> Self {
        _append(columns.map { .init(name: $0, alias: nil) })
        return self
    }
    
    @discardableResult
    public func select(_ columns: [ColumnAttribute]) -> Self {
        _append(columns)
        return self
    }
    
    private(set) var columnQueryJoins = [Join<ColumnQuery>]()
    
    @discardableResult
    public func join<Q>(_ queryConvertible: Q, as alias: String? = nil, on left: String, equal right: String) -> Self where Q : ColumnQueryConvertible {
        columnQueryJoins.append(Join(type: .inner, joinedQuery: ColumnQuery(other: queryConvertible.query),
                                     rightAlias: alias, leftColumn: left, rightColumn: right))
        return self
    }

    @discardableResult
    public func leftJoin<Q>(_ queryConvertible: Q, as alias: String? = nil, on left: String, equal right: String) -> Self where Q : ColumnQueryConvertible {
        columnQueryJoins.append(Join(type: .leftOuter, joinedQuery: ColumnQuery(other: queryConvertible.query),
                                     rightAlias: alias, leftColumn: left, rightColumn: right))
        return self
    }
    
//    private(set) var neutJoins = [Join<NeutQuery<ColumnQuery>>]()
//    
//    @discardableResult
//    public func join<T>(_ query: NeutQuery<ColumnQuery<T>>, as alias: String? = nil, on left: String, equal right: String) -> Self  {
//        neutJoins.append(Join(type: .inner, joinedQuery: NeutQuery(other: query), rightAlias: alias, leftColumn: left, rightColumn: right))
//        return self
//    }
//    
//    @discardableResult
//    public func leftJoin<T>(_ query: NeutQuery<ColumnQuery<T>>, as alias: String? = nil, on left: String, equal right: String) -> Self {
//        neutJoins.append(Join(type: .leftOuter, joinedQuery: NeutQuery(other: query), rightAlias: alias, leftColumn: left, rightColumn: right))
//        return self
//    }
//    
    private(set) var orderedColumns = [Order]()
    
    @discardableResult
    public func order(_ orders: Order...) -> Self {
        orderedColumns.append(contentsOf: orders)
        return self
    }
    
    @discardableResult
    public func order(_ orders: [Order]) -> Self {
        orderedColumns.append(contentsOf: orders)
        return self
    }
}

extension ColumnQuery {
    public var query: ColumnQuery<Result> {
        return self
    }
}

extension ColumnQueryConvertible {
    public func limit(count: Int = 20, isAutoPageIncrement: Bool = true) -> QuerySession<Self> {
        return QuerySession(session: self, count: count, isAutoPageIncrement: isAutoPageIncrement)
    }
}

public protocol SessionQuery {
    associatedtype Result
}

public class QuerySession<S: SessionQuery> {

    let session : S

    public var page: Int = 1
    public let count: Int
    public var paginationInfo: Any? = nil
    internal let isAutoPageIncrement: Bool

    init(session: S, count: Int, isAutoPageIncrement: Bool = true) {
        self.session = session
        self.count = count
        self.isAutoPageIncrement = isAutoPageIncrement
    }

    init<T>(session: S, other: QuerySession<T>) {
        self.session = session
        self.page = other.page
        self.paginationInfo = other.paginationInfo
        self.count = other.count
        self.isAutoPageIncrement = other.isAutoPageIncrement
    }
    
}
