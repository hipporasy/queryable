@attached(member, names: named(CodingKeys), named(init(from:)))
@attached(conformance)
public macro Entity() = #externalMacro(module: "QueryableMacros", type: "EntityMacro")

@attached(member)
public macro CodingKey(_ key: String) = #externalMacro(module: "QueryableMacros", type: "CodingKeyMacro")

@attached(member)
public macro Ignored() = #externalMacro(module: "QueryableMacros", type: "IgnoredMacro")

