// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "RequiresMacro",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "RequiresMacro", targets: ["RequiresMacro"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            exact: "603.0.2"
        )
    ],
    targets: [
        .macro(
            name: "RequiresMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "RequiresMacro", dependencies: ["RequiresMacroPlugin"]),
        .testTarget(
            name: "RequiresMacroTests",
            dependencies: [
                "RequiresMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
