import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import QueryableMacros

let entityMacro: [String: Macro.Type] = [
    "Entity": EntityMacro.self
]




final class QueryableTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @Entity struct Hero {
                let character: String
            }
            """,
            expandedSource: """
            struct Hero {
                let character: String
                enum CodingKeys: String, CodingKey, CaseIterable {
                    case character = "character"
                }
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    character = try container.decode(String.self, forKey: .character)
                }
            }
            extension Hero: EntitySpecific, CodingKeyIterable, Decodable {
                static var entityName: String {
                    "Hero"
                }
            }
            """
            ,
            macros: entityMacro
        )
    }

//    func testMacroWithStringLiteral() {
//        assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//        )
//    }
}
