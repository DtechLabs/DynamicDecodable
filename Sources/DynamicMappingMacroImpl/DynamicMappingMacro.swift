//
//  DynamicMappingMacro.swift
//  DynamicMappingMacro
//
//  Created by Yury Dryhin on 04.06.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DynamicMappingMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

@main
struct DynamicMappingMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DynamicMappingMacro.self,
    ]
}
