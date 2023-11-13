# Queryable
Swift Macro with Query 
Apple has just released the [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
I don't know what should be a good name for this repository but I called it Queryable at the moment 

## Goal 

The goal here is just to work with Macros 
- ORM style
- Make the query with conditions
- Make the join condition to make it compatiable with SQL
- Adding the adapter into GraphQL, Strapi, Firebase, GRDB, SQLLite ...etc

### End Goal
```
@Entity
struct Hero {
    let id: String
    let character: String?
    @Ignored
    var level: Int?
    @CodingKey("total_score")
    let totalScore: Double
}

@Entity
struct Mission {
    let id: String
    let difficulty: String
    let totalScore: Double
}

@Entity
struct HeroMission {
    let id: String
    let mission: Mission
    let hero: Hero
}

let query = HeroMission
    .columnQuery()
    .join(Hero.columnQuery(), key: .hero)
    .join(Mission.columnQuery(), key: .mission)

let results = fetch(query)
```
