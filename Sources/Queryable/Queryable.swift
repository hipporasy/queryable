@attached(member, names: named(CodingKeys), named(init(from:)))
@attached(extension, conformances: EntitySpecific, CodingKeyIterable, Decodable, names: named(entityName))
public macro Entity() = #externalMacro(module: "QueryableMacros", type: "EntityMacro")

@attached(peer)
public macro CodingKey(_ key: String) = #externalMacro(module: "QueryableMacros", type: "CodingKeyMacro")

@attached(peer)
public macro Ignored() = #externalMacro(module: "QueryableMacros", type: "IgnoredMacro")

