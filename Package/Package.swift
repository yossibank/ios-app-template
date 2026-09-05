// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "ScreenCore", targets: ["ScreenCore"]),
        .library(name: "SharedCore", targets: ["SharedCore"]),
        .library(name: "FeatureHome", targets: ["FeatureHome"]),
        .library(name: "AppRoot", targets: ["AppRoot"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/yossibank/kmp-app-template.git",
            exact: "0.7.0"
        ),
        .package(path: "../Macro/RequiresMacro")
    ],
    targets: [
        // 画面の土台。純粋な Swift / SwiftUI で、共通コアに依存しない。
        .target(
            name: "ScreenCore",
            dependencies: [
                .product(name: "RequiresMacro", package: "RequiresMacro")
            ]
        ),
        // 共通コアを import してよい唯一のモジュール。
        .target(
            name: "SharedCore",
            dependencies: [
                .product(name: "Shared", package: "kmp-app-template")
            ]
        ),
        .target(
            name: "FeatureHome",
            dependencies: ["ScreenCore", "SharedCore"]
        ),
        .target(
            name: "AppRoot",
            dependencies: ["FeatureHome"]
        )
    ]
)
