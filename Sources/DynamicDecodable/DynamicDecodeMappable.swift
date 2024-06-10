//
//  DynamicDecodeMappable.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 31.05.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

import Foundation

public protocol DynamicDecodeMappable {
    
    init?(_ data: DynamicDecodable?)
    
}

@attached(extension, conformances: DynamicDecodeMappable, names: named(init))
public macro DynamicDecodableMapping() = #externalMacro(module: "DynamicDecodeMappingMacros", type: "DynamicDecodeMappingMacro")
