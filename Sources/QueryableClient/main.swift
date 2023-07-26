import Queryable


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
struct Bottle {
    let id: String
    let color: String
}
