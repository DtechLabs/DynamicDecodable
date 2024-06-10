import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(DynamicDecodeMappingMacros)
import DynamicDecodeMappingMacros
import DynamicDecodable

let testMacros: [String: Macro.Type] = [
    "DynamicDecodableMapping": DynamicDecodeMappingMacro.self,
]
#endif

final class DynamicDecodableMappingTests: XCTestCase {
    
    func testFailedApplyToClass() throws {
        #if canImport(DynamicDecodeMappingMacros)
        assertMacroExpansion(#"""
                @DynamicDecodableMapping
                class MyItem {
                    var id: Int
                    var name: String
                }
                """#,
                expandedSource: #"""
                class MyItem {
                    var id: Int
                    var name: String
                }
                """#,
                diagnostics: [
                    DiagnosticSpec(message: "@DynamicDecodeMapping can only be applied to a structure or enum", line: 1, column: 1)
                ],
                macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testSimpleStruct() throws {
        #if canImport(DynamicDecodeMappingMacros)
        assertMacroExpansion(#"""
            @DynamicDecodableMapping
            struct MyItem {
                let id: Int
                let name: String
            }
            """#,
            expandedSource:#"""
            struct MyItem {
                let id: Int
                let name: String
            }
            
            extension MyItem: DynamicDecodeMappable {
                init?(_ data: DynamicDecodable?) {
                    guard let data = data, let id = data.id?.intValue, let name = data.name?.stringValue else {
                        return nil
                    }
                    self.id = id
                    self.name = name
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testOptionalStruct() throws {
        #if canImport(DynamicDecodeMappingMacros)
        assertMacroExpansion(#"""
            @DynamicDecodableMapping
            struct MyItem {
                let id: Int
                let name: String
                let amount: Decimal?
                let isVip: Bool?
            }
            """#,
            expandedSource:#"""
            struct MyItem {
                let id: Int
                let name: String
                let amount: Decimal?
                let isVip: Bool?
            }
            
            extension MyItem: DynamicDecodeMappable {
                init?(_ data: DynamicDecodable?) {
                    guard let data = data, let id = data.id?.intValue, let name = data.name?.stringValue else {
                        return nil
                    }
                    self.id = id
                    self.name = name
                    self.amount = data.amount?.decimalValue
                    self.isVip = data.isVip?.boolValue
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testNestedStructure() throws {
        #if canImport(DynamicDecodeMappingMacros)
            assertMacroExpansion(#"""
            @DynamicDecodableMapping
            struct MyItem {
                let id: Int
                let name: String
                let flag: SomeFlag
                let asset: Asset?
            
                var computed: Bool {
                    true
                }
            
                var someVar2: Int = 3
            }
            """#,
            expandedSource: #"""
            struct MyItem {
                let id: Int
                let name: String
                let flag: SomeFlag
                let asset: Asset?
            
                var computed: Bool {
                    true
                }
            
                var someVar2: Int = 3
            }
            
            extension MyItem: DynamicDecodeMappable {
                init?(_ data: DynamicDecodable?) {
                    guard let data = data, let id = data.id?.intValue, let name = data.name?.stringValue, let flag = SomeFlag(data.flag) else {
                        return nil
                    }
                    self.id = id
                    self.name = name
                    self.flag = flag
                    self.asset = Asset(data.asset)
                }
            }
            """#,
            diagnostics: [],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
 
    func testEnum() throws {
        #if canImport(DynamicDecodeMappingMacros)
        assertMacroExpansion(#"""
            @DynamicDecodableMapping
            enum MyOption: String {
                case one
                case two
                case three
            }
            """#,
            expandedSource:#"""
            enum MyOption: String {
                case one
                case two
                case three
            }
            
            extension MyOption: DynamicDecodeMappable {
                init?(_ data: DynamicDecodable?) {
                    guard let rawValue = data?.stringValue, let value = MyOption(rawValue: rawValue) else {
                        return nil
                    }
                    self = value
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testNestedArray() throws {
        #if canImport(DynamicDecodeMappingMacros)
            assertMacroExpansion(#"""
                @DynamicDecodableMapping
                struct MyItem {
                    let assets: [Asset]
                    let images: [File]?
                    let ids: [Int]
                }
                """#,
            expandedSource: #"""
                struct MyItem {
                    let assets: [Asset]
                    let images: [File]?
                    let ids: [Int]
                }
                
                extension MyItem: DynamicDecodeMappable {
                    init?(_ data: DynamicDecodable?) {
                        guard let data = data, let assets = data.assets?.array, let ids = data.ids?.array else {
                            return nil
                        }
                        self.assets = assets.compactMap {
                            Asset($0)
                        }
                        self.ids = ids.compactMap {
                            $0.intValue
                        }
                        self.images = data.images?.array?.compactMap {
                            File($0)
                        }
                    }
                }
                """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
