import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import QueryableMacros

let entityMacro: [String: Macro.Type] = [
    "Entity": EntityMacro.self
]




final class QueryableTests: XCTestCase {
    func testEntityMacro() {
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
    
    func fieldWithCustomName() {
        assertMacroExpansion(
            """
            @Entity struct Hero {
                @CodingKey("char")
                let character: String
            }
            """,
            expandedSource: """
            struct Hero {
                let character: String
                enum CodingKeys: String, CodingKey, CaseIterable {
                    case character = "char"
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
            """,
            macros: entityMacro
        )
    }
    
    func throwErrorWhenApplyEntityToNonClassOrStruct() {
        
    }

}
