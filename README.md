# DynamicDecodable

DynamicDecodable is a lightweight Swift framework designed to handle dynamic JSON data structures in a robust and efficient manner. It aims to solve common issues encountered when backend data structures change, often leading to app crashes or malfunctioning, especially in strictly typed languages like Swift.

## Problem Statement

In real-world applications, backend data structures may change frequently, causing significant issues for client applications that rely on static typing. Specifically, Swift’s `Codable` protocol, while powerful, is inherently limited by Swift’s strict type system. This can lead to several problems:

1. **Inconsistent Data Types**: For instance, a boolean value might be received in different forms such as [true | false], [1 | 0], or even as strings ["true" | "false"]. Similarly, numbers can appear as either numeric values or string representations, and dates can have multiple formats.

2. **Variable Response Structures**: Different endpoints performing similar actions might return slightly different sets of properties, causing difficulties in maintaining a consistent data model.

## Solution

To address these issues, DynamicDecodable provides a flexible and dynamic approach to JSON deserialization. It leverages JSONSerialization and dynamicMemberLookup to handle varying data types and structures seamlessly.

### Features

- **Dynamic Type Handling**: Supports primary JSON data types such as `number`, `string`, `boolean`, `array`, `dictionary`, and `null`.
- **Syntactic Sugar**: Provides clean and readable code syntax for easy data access and manipulation.
- **Optional Members**: Ensures that all dynamic members are optional to prevent runtime crashes.

## Installation

DynamicDecodable can be installed via Swift Package Manager. Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DtechLabs/DynamicDecodable.git", from: "1.0.0")
]
```

## Usage

### Initialization

Initialize `DynamicDecodable` with JSON data:

```swift
let item = try DynamicDecodable(jsonData)
```

### Accessing Data

Accessing various data types:

```swift
let name = item.name.stringValue
let id = item.id.intValue
let amount = item.decimalValue // Decimal is preferred to avoid Double rounding errors
let createdAt = item.createdAt.date
```

Using syntactic sugar for cleaner code, especially when updating data in a defined structure:

```swift
let id: Int <- item.id
```

### Working with Arrays

Accessing array elements:

```swift
let asset1 = item.assets?[0]
```

### Working with Date

DynamicDecodable supports two Swift DateFormatters to parse date from string.

1.  `ISODateFormatter`.

    By default use this format options: `[.withFullDate, .withFullTime, .withFractionalSeconds]` - parse string like this "2024-05-06T14:05:23.000000Z"

    And `[.withInternetDateTime]` for others.

    You can add or remove options `DynamicDecodable.isoDateFormatOptions`

    if IOSDateFormatter fails to parse the date trying next

2.  `DateFormatter`.

    By default formats `DynamicDecodable.dateFormats` is empty, but you can add what you wants.

isoDateFormatOptions and then dateFormats will be apply until the date is parsing successful so order is matter. Check what you need

Also you can set custom TimeZone `DynamicDecodable.timeZone`. By default this property is nil

### Equality and Comparison

Simple types equality check. Apply for `int`, `string`, `bool`, `date`, `double`, and `decimal`:

```swift
if item.name == "user" {
    // Do something
}

if item.amount > 100 {
    // Do something
}

// Filter or Found array elements as usual
let itemTwo = data2.items?.array?.first { $0.id == 2 }
```

## Contribution

If you have any questions or proposals to add functionality, please feel free to contact me. Contributions to enhance the framework are always welcome.

## License

DynamicDecodable is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

## Contact

You can contact me at: yuri.drigin@icloud.com
or on [LinkedIn:](https://www.linkedin.com/in/dtechlabs/)
