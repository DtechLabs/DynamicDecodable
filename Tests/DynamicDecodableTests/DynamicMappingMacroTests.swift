import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import DynamicDecodable

#if canImport(DynamicMappingMacroImpl)
import DynamicMappingMacroImpl

let testsMacros = ["DynamicMappingMacro": DynamicMappingMacro.self]

#endif

final class DynamicMappingMacroTests: XCTestCase {
    
    func testDynamicMapping() throws {
        #if canImport(DynamicMappingMacroImpl)
        assertMacroExpansion(
            """
            @DynamicMapping
            struct MyItem {
                let id: Int
                let name: String
                let amount: Decimal
                let isVip: Bool
                let reference: String?
            }
            """,
            expandedSource:
            """
            struct MyItem {
                let id: Int
                let name: String
                let amount: Decimal
                let isVip: Bool
                let reference: String?
            
                init?(_ data: DynamicDecodable?) {
                    guard let data = data else {
                        return nil
                    }
                }
            }
            """,
            macros: testsMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}

