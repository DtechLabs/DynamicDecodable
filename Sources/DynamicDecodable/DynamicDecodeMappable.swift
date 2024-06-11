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

/// A macro that generates an optional initializer for a structure or enum conforming to the `DynamicDecodeMappable` protocol.
/// ```swift
/// extension SomeItem: DynamicDecodeMappable {
///     init?(_ data: DynamicDecodable?) {
///         ...
///     }
/// }
/// ```
///
/// - Usage:
/// ```swift
/// @DynamicDecodableMapping
/// struct SomeItem {
///     let id: Int
///     let name: String
///     let balance: Decimal?
///     let avatarBig: URL?
/// }
/// ```
///
/// - Note: Structure must contain only ``DynamicDecodable`` supported types:
/// `Int`, `String`, `Double`, `Decimal`, `Bool`, `Date`, `URL` and
/// nested structures and enums that also confirmed ``DynamicDecodeMappable``. In other cases, you should map the data manually.
/// The mapped types should have property names matching those in JSON.
/// ``DynamicDecodable`` can automatically convert camelCase to snake_case and vice versa.
/// If the properties need to be mapped with different names or under specific conditions, this should also be done manually.
/// Computed properties and initialized properties are ignored.
@attached(extension, conformances: DynamicDecodeMappable, names: named(init))
public macro DynamicDecodableMapping() = #externalMacro(module: "DynamicDecodeMappingMacros", type: "DynamicDecodeMappingMacro")
