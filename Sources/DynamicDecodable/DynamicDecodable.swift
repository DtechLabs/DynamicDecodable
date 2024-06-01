//
//  DynamicDecodable.swift
//  DynamicDecodable
//
//  Created by Yury Dryhin on 31.05.2024.
//  Copyright © 2024 . All rights reserved.
//
//  This software is released under the MIT License.
//

import Foundation

public enum DynamicDecodableError: Error {
    case unsupportedType(String)
}

@dynamicMemberLookup
indirect public enum DynamicDecodable {
    
    public static var dateFormats: [String] = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd HH:mm:ss"
    ]
    
    case int(Int)
    case string(String)
    case bool(Bool)
    case double(Double)
    case array([DynamicDecodable])
    case dictionary([String: DynamicDecodable])
    case null
    
    public init(_ data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data)
        self = try DynamicDecodable(json)
    }
    
    public init(_ value: Any) throws {
        switch value {
            case is Int:
                self = .int(value as! Int)
            case is Bool:
                self = .bool(value as! Bool)
            case is String:
                self = .string(value as! String)
            case is Double:
                self = .double(value as! Double)
            case is Array<Any>:
                let array = value as! Array<Any>
                let dynamicArray = try array.map { try DynamicDecodable($0) }
                self = .array(dynamicArray)
            case is [String: Any]:
                let dictionary = value as! [String: Any]
                let dynamicDictionary = try dictionary.reduce(into: [String: DynamicDecodable](), { dict, item in
                    dict[item.key] = try DynamicDecodable(item.value)
                })
                self = .dictionary(dynamicDictionary)
            case is NSNull:
                self = .null
            default:
                throw DynamicDecodableError.unsupportedType(String(describing: value))
        }
    }
    
    public subscript(dynamicMember member: String) -> DynamicDecodable? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        return dictionary[member.asSnakeCase] ?? dictionary[member]
    }
    
    public subscript(index: Int) -> DynamicDecodable? {
        guard case .array(let array) = self else {
            return nil
        }
        return array[index]
    }
    
    public var intValue: Int? {
        guard case .int(let int) = self else {
            return nil
        }
        return int
    }
    
    public var stringValue: String? {
        guard case .string(let string) = self else {
            return nil
        }
        return string
    }
    
    public var boolValue: Bool? {
        switch self {
            case .bool(let value):
                return value
            case .string(let str):
                switch str.lowercased() {
                    case "true": return true
                    case "false": return false
                    default: return nil
                }
            case .int(let value):
                if value == 0 {
                    return false
                } else if value == 1 {
                    return true
                } else {
                    return nil
                }
            default:
                return nil
        }
    }
    
    public var doubleValue: Double? {
        switch self {
            case .double(let value): value
            case .string(let str): Double(str)
            default: nil
        }
    }
    
    public var decimalValue: Decimal? {
        switch self {
            case .double(let value):
                // We convert through string because there can be a rounding error.
                return Decimal(string: value.description)
            case .string(let str):
                return Decimal(string: str, locale: Locale.init(identifier: "en-US"))
            case .int(let value):
                return Decimal(value)
            default:
                return nil
        }
    }
    
    public var url: URL? {
        guard case .string(let string) = self else {
            return nil
        }
        return URL(string: string)
    }
    
    public var date: Date? {
        switch self {
            case .int(let value):
                return Date(timeIntervalSince1970: Self.timeIntervalInSeconds(value))
            case .double(let value):
                return Date(timeIntervalSince1970: value)
            case .string(let str):
                if let date = ISO8601DateFormatter().date(from: str) {
                    return date
                } else {
                    let formatter = DateFormatter()
                    for format in Self.dateFormats {
                        formatter.dateFormat = format
                        if let date = formatter.date(from: str) {
                            return date
                        }
                    }
                    return nil
                }
            default:
                return nil
        }
    }
    
    public var array: [DynamicDecodable]? {
        guard case .array(let array) = self else {
            return nil
        }
        return array
    }
    
    public var dictionary: [String: DynamicDecodable]? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        return dictionary
    }
    
    static private func timeIntervalInSeconds(_ value: Int) -> TimeInterval {
        value > 10_000_000_000 ? TimeInterval(value / 1_000) : TimeInterval(value)
    }
    
}

extension DynamicDecodable: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
            case .int(let value): value.description
            case .string(let string): string
            case .bool(let value): value.description
            case .double(let value): value.description
            case .array(let array): array.map { $0.description }.joined(separator: ";")
            case .dictionary(let dict): dict.map { "\($0.key):\($0.value)" }.joined(separator: ";")
            case .null: "null"
        }
    }
    
    public var debugDescription: String {
        switch self {
            case .int(let value): "Dynamic Int \(value)"
            case .string(let string): "Dynamic String \(string)"
            case .bool(let value):  "Dynamic Bool \(value)"
            case .double(let value): "Dynamic Double \(value)"
            case .array(let array): "Dynamic array \(array.map { $0.description }.joined(separator: ";"))"
            case .dictionary(let dict): "Dynamic dictionary \(dict.map { "\($0.key):\($0.value)" }.joined(separator: ";"))"
            case .null: "Dynamic null"
        }
    }
    
}

extension DynamicDecodable: Equatable {
    
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
        lhs.date == rhs
    }
    
}

extension Optional where Wrapped == DynamicDecodable {
    
    public static func ==(lhs: DynamicDecodable?, rhs: String) -> Bool {
        lhs?.stringValue == rhs
    }
    

    public static func ==(lhs: DynamicDecodable?, rhs: Int) -> Bool {
        lhs?.intValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Bool) -> Bool {
        lhs?.boolValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Decimal) -> Bool {
        lhs?.decimalValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Double) -> Bool {
        lhs?.doubleValue == rhs
    }
    
    public static func ==(lhs: DynamicDecodable?, rhs: Date) -> Bool {
        lhs?.date == rhs
    }
}

// MARK: Assignment Operators
infix operator <-: AssignmentPrecedence

extension RawRepresentable where RawValue == String {
    
    public static func <-(lhs: inout Self, rhs: DynamicDecodable?) {
        guard  let rhs = rhs else {
            return
        }
        
        guard let value = Self(rawValue: rhs.stringValue ?? "") else {
            debugPrint("Wrong value for RawRepresentable: ", rhs.description)
            return
        }
        lhs = value
    }
}

// MARK: Date
public extension Date {
    
    static func <-(lhs: inout Date, rhs: DynamicDecodable?) {
        if let newDate = rhs?.date {
            lhs = newDate
        }
    }
    
}

public extension Optional where Wrapped == Date {
    
    static func <-(lhs: inout Optional, rhs: DynamicDecodable?) {
        lhs = rhs?.date
    }
    
}

// MARK: Int
public extension Int {
    
    static func <-(lhs: inout Int, rhs: DynamicDecodable?) {
        if let newDValue = rhs?.intValue {
            lhs = newDValue
        }
    }
    
}

public extension Optional where Wrapped == Int {
    
    static func <-(lhs: inout Optional, rhs: DynamicDecodable?) {
        lhs = rhs?.intValue
    }
    
}


// MARK: String
public extension String {
    
    static func <-(lhs: inout String, rhs: DynamicDecodable?) {
        if let newValue = rhs?.stringValue {
            lhs = newValue
        }
    }
    
}

public extension Optional where Wrapped == String {
    
    static func <-(lhs: inout Optional, rhs: DynamicDecodable?) {
        lhs = rhs?.stringValue
    }
    
}

// MARK: Bool
public extension Bool {
    
    static func <-(lhs: inout Bool, rhs: DynamicDecodable?) {
        if let newValue = rhs?.boolValue {
            lhs = newValue
        }
    }
    
}

public extension Optional where Wrapped == Bool {
    
    static func <-(lhs: inout Optional, rhs: DynamicDecodable?) {
        lhs = rhs?.boolValue
    }
    
}

// MARK: Decimal
public extension Decimal {
    
    static func <-(lhs: inout Decimal, rhs: DynamicDecodable?) {
        if let newValue = rhs?.decimalValue {
            lhs = newValue
        }
    }
    
}

public extension Optional where Wrapped == Decimal {
    
    static func <-(lhs: inout Optional, rhs: DynamicDecodable?) {
        lhs = rhs?.decimalValue
    }
    
}
