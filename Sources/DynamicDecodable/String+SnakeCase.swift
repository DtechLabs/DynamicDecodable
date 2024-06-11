//
//  String+SnakeCase.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 31.05.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

import Foundation

public extension DynamicDecodable {
    
    static func stringAsSnakeCase(_ str: String) -> String {
        let regex = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])")
        let range = NSRange(location: 0, length: str.utf16.count)
        let snakeCasedString = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "$1_$2")
        return snakeCasedString.lowercased()
    }
    
}
