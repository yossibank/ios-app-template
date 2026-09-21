// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Package",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "ScreenCore",
            targets: ["ScreenCore"]
        ),
        .library(
            name: "SharedCore",
            targets: ["SharedCore"]
        ),
        .library(
            name: "FeatureHome",
            targets: ["FeatureHome"]
        ),
        .library(
            name: "AppRoot",
            targets: ["AppRoot"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/yossibank/kmp-app-template.git",
            exact: "0.15.0"
        )
    ],
    targets: [
        .target(
            name: "ScreenCore",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SharedCore",
            dependencies: [
                .product(
                    name: "Shared",
                    package: "kmp-app-template"
                )
            ]
        ),
        .target(
            name: "FeatureHome",
            dependencies: ["ScreenCore", "SharedCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppRoot",
            dependencies: ["FeatureHome"]
        ),
        .testTarget(
            name: "ScreenCoreTests",
            dependencies: ["ScreenCore"]
        ),
        .testTarget(
            name: "FeatureHomeTests",
            dependencies: ["FeatureHome"]
        )
    ]
)
