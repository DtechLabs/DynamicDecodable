// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "DynamicDecodable",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DynamicDecodable",
            targets: ["DynamicDecodable"]
        ),
        .executable(
            name: "DynamicDecodableExampleApp",
            targets: ["DynamicDecodableExampleApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "DynamicDecodeMappingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "DynamicDecodable",
            plugins: [.plugin(name: "DynamicDecodeMappingMacros")]
        ),
        .executableTarget(
            name: "DynamicDecodableExampleApp",
            dependencies: ["DynamicDecodable"]
        ),
        .testTarget(
            name: "DynamicDecodableTests",
            dependencies: [
                "DynamicDecodable"
            ]
        ),
        .testTarget(
            name: "DynamicDecodeMappingTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            plugins: [.plugin(name: "DynamicDecodeMappingMacros")]
        )
    ]
)
