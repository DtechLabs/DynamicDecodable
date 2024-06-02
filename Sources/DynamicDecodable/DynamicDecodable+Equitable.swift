//
//  DynamicDecodable+Equitable.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 31.05.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//


import Foundation

extension DynamicDecodable {

    public static func ==(lhs: DynamicDecodable, rhs: String) -> Bool {
        lhs.stringValue == rhs
    }

    public static func ==(lhs: DynamicDecodable, rhs: Int) -> Bool {
        lhs.intValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable, rhs: Bool) -> Bool {
        lhs.boolValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable, rhs: Decimal) -> Bool {
        lhs.decimalValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable, rhs: Double) -> Bool {
        lhs.doubleValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable, rhs: Date) -> Bool {
        lhs.dateValue == rhs
    }
    
}

extension Optional where Wrapped == DynamicDecodable {
    
    public static func ==(lhs: DynamicDecodable?, rhs: String) -> Bool {
        lhs?.stringValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Bool) -> Bool {
        lhs?.boolValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Double) -> Bool {
        lhs?.doubleValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Date) -> Bool {
        lhs?.dateValue == rhs
    }
    
    // MARK: Decimal
    public static func ==(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        lhs?.decimalValue == rhs
    }
    
    public static func <(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        guard let value = lhs?.decimalValue else {
            return false
        }
        return value < rhs
    }
    
    public static func >(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        !(lhs < rhs)
    }
    
    public static func >=(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        (lhs > rhs) || (lhs == rhs)
    }
    
    public static func <=(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        (lhs < rhs) || (lhs == rhs)
    }
    
    
    // MARK: Int
    public static func ==(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        lhs?.intValue == rhs
    }
    
    public static func <(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        guard let value = lhs?.intValue else {
            return false
        }
        return value < rhs
    }
    
    public static func >(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        !(lhs < rhs)
    }
    
    public static func >=(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        (lhs > rhs) || (lhs == rhs)
    }
    
    public static func <=(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        (lhs < rhs) || (lhs == rhs)
    }
    
}
