//
//  DynamicMapping.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 04.06.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

@attached(member, names: named(init))
public macro DynamicMapping() = #externalMacro(module: "DynamicMappingMacroImpl", type: "DynamicMappingMacro")

