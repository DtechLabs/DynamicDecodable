//
//  DynamicDecodeMappingMacro.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 31.05.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum DynamicMappingError: CustomStringConvertible, Error {
    
    case onlyApplicableToStructOrEnum
    case unsupportedVariableType(TypeSyntax)
    case unsupportedEnumRawType
    
    public var description: String {
        switch self {
            case .onlyApplicableToStructOrEnum: return "@DynamicDecodeMapping can only be applied to a structure or enum"
            case .unsupportedVariableType(let type):
                return "@DynamicMapping cannot be apply when property is \(type.description)"
            case .unsupportedEnumRawType:
                return "@DynamicMapping cannot be apply to enum with this raw type"
        }
    }
}

/// Implementation of the `DynamicDecodeMapping` macro
/// Ignoring computed or initialized variables
/// All custom types counting as `DynamicDecodeMapping`
public struct DynamicDecodeMappingMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return try [expansion(structDecl, type: type)]
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return try [expansion(enumDecl, type: type)]
        } else {
            throw DynamicMappingError.onlyApplicableToStructOrEnum
        }
        
    }
    
    private static func expansion(_ structDecl: StructDeclSyntax, type: TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        let members = structDecl.memberBlock.members
        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let strongVariables = Self.getStrongVariables(variableDecls)
        let optionalVariables = Self.getOptionalVariables(variableDecls)
        
        return try ExtensionDeclSyntax("extension \(raw: type.trimmed.description): DynamicDecodeMappable") {
            try InitializerDeclSyntax("init?(_ data: DynamicDecodable?)") {
                GuardStmtSyntax(
                    guardKeyword: .keyword(.guard),
                    conditions: try Self.buildGuardConditions(strongVariables),
                    elseKeyword: .keyword(.else),
                    body: CodeBlockSyntax(statements: "return nil")
                )
                
                for (name, type) in strongVariables {
                    if let arrayType = type.as(ArrayTypeSyntax.self) {
                        let element = arrayType.element.trimmed
                        if let simpleType = try Self.mapTypeSyntax(element) {
                            ExprSyntax("self.\(name) = \(name).compactMap { $0.\(raw: simpleType) }")
                        } else  {
                            ExprSyntax("self.\(name) = \(name).compactMap { \(element)($0) }")
                        }
                    } else {
                        ExprSyntax("self.\(name) = \(name)")
                    }
                }
                
                for (name, type) in optionalVariables {
                    if let arrayType = type.as(ArrayTypeSyntax.self) {
                        let element = arrayType.element.trimmed
                        if let simpleType = try Self.mapTypeSyntax(element) {
                            ExprSyntax("self.\(name) = data.\(name)?.array?.compactMap { $0.\(raw: simpleType) }")
                        } else  {
                            ExprSyntax("self.\(name) = data.\(name)?.array?.compactMap { \(element)($0) }")
                        }
                    } else if let typeDesc = try Self.mapTypeSyntax(type) {
                        ExprSyntax("self.\(name) = data.\(name)?.\(raw: typeDesc)")
                    } else {
                        ExprSyntax("self.\(name) = \(type)(data.\(name))")
                    }
                }
            }
        }
    }
    
    private static func expansion(_ enumDecl: EnumDeclSyntax, type: TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        guard let rawType = enumDecl.inheritanceClause?.inheritedTypes.first?.type.trimmed else {
            throw DynamicMappingError.unsupportedEnumRawType
        }
        return try ExtensionDeclSyntax("extension \(raw: type.description): DynamicDecodeMappable") {
            try InitializerDeclSyntax("init?(_ data: DynamicDecodable?)") {
                GuardStmtSyntax(
                    guardKeyword: .keyword(.guard),
                    conditions: try Self.buildGuardEnumConditions(rawType, type: type),
                    elseKeyword: .keyword(.else),
                    body: CodeBlockSyntax(statements: "return nil")
                )
                
                ExprSyntax("self = value")
            }
        }
    }
    
    static private func getStrongVariables(_ allVariables: [VariableDeclSyntax]) -> [(PatternSyntax, TypeSyntax)] {
        allVariables.compactMap {
            guard
                let decl = $0.bindings.first,
                decl.initializer == nil,
                decl.accessorBlock == nil,
                let type = decl.typeAnnotation?.type,
                !type.is(OptionalTypeSyntax.self)
            else {
                return nil
            }
            return (decl.pattern.trimmed, type)
        }
    }
    
    static private func getOptionalVariables(_ allVariables: [VariableDeclSyntax]) -> [(PatternSyntax, TypeSyntax)] {
        allVariables.compactMap {
            guard
                let decl = $0.bindings.first,
                decl.initializer == nil,
                decl.accessorBlock == nil,
                let type = decl.typeAnnotation?.type,
                let optionalType = type.as(OptionalTypeSyntax.self)
            else {
                return nil
            }
            
            return (decl.pattern.trimmed, optionalType.wrappedType)
        }
    }
    
    static private func mapTypeSyntax(_ type: TypeSyntax) throws -> String? {
        if type.is(ArrayTypeSyntax.self) {
            return "array"
        }
        
        switch type.description {
            case "Int":
                return "intValue"
            case "String":
                return "stringValue"
            case "Decimal":
                return "decimalValue"
            case "Date":
                return "dateValue"
            case "URL":
                return "url"
            case "Double":
                return "doubleValue"
            case "Bool":
                return "boolValue"
            case "Int8", "Int16", "Int32", "Int64":
                fallthrough
            case "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
                fallthrough
            case "Float":
                throw DynamicMappingError.unsupportedVariableType(type)
            default:
                return nil
        }
    }
    
    static private func buildGuardEnumConditions(_ rawType: TypeSyntax, type: TypeSyntaxProtocol) throws -> ConditionElementListSyntax {
        guard
            rawType.description == "String" || rawType.description == "Int",
            let typeDesc = try Self.mapTypeSyntax(rawType)
        else {
            throw DynamicMappingError.unsupportedEnumRawType
        }
        
        let rawBinding = OptionalBindingConditionSyntax(
            bindingSpecifier: .keyword(.let),
            pattern: PatternSyntax("rawValue"),
            initializer: .init(value: ExprSyntax("data?.\(raw: typeDesc)"))
        )
        
        let typeName = type.trimmed.description
        let exp: ExprSyntax = if rawType.description == "String" {
             "\(raw: typeName)(rawValue: rawValue) ?? \(raw: typeName)(rawValue: Self.stringAsSnakeCase(rawValue))"
        } else {
            "\(raw: typeName)(rawValue: rawValue)"
        }
        let valueBinding = OptionalBindingConditionSyntax(
            bindingSpecifier: .keyword(.let),
            pattern: PatternSyntax("value"),
            initializer: .init(value: exp)
        )
        
        return [
            .init(
                condition: .optionalBinding(rawBinding),
                trailingComma: .commaToken()
            ),
            .init(
                condition: .optionalBinding(valueBinding)
            )
        ]
    }
    
    static private func buildGuardConditions(_ variables: [(PatternSyntax, TypeSyntax)]) throws -> ConditionElementListSyntax {
        let dataBinding = OptionalBindingConditionSyntax(
            bindingSpecifier: .keyword(.let),
            pattern: PatternSyntax("data"),
            initializer: .init(value: ExprSyntax("data"))
        )
        
        var result: ConditionElementListSyntax = [
            .init(
                condition: .optionalBinding(dataBinding),
                trailingComma: .commaToken()
            )
        ]
        
        for (index, (name, type)) in variables.enumerated() {
            let syntax: ExprSyntax = if let typeDesc = try Self.mapTypeSyntax(type) {
                "data.\(name)?.\(raw: typeDesc)"
            } else {
                "\(type)(data.\(name))"
            }
            
            let variableBinding = OptionalBindingConditionSyntax(
                bindingSpecifier: .keyword(.let),
                pattern: PatternSyntax(name),
                initializer: .init(value: syntax)
            )
            
            result.append(
                .init(
                    condition: .optionalBinding(variableBinding),
                    trailingComma: index == variables.indices.last ? nil : .commaToken()
                )
            )
        }
        return result
    }
    
}

@main
struct DynamicDecodableMappingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DynamicDecodeMappingMacro.self,
    ]
}
