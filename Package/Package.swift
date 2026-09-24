// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
]

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
            exact: "0.18.1"
        )
    ],
    targets: [
        .target(
            name: "ScreenCore",
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SharedCore",
            dependencies: [
                .product(
                    name: "Shared",
                    package: "kmp-app-template"
                )
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FeatureHome",
            dependencies: ["ScreenCore", "SharedCore"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "AppRoot",
            dependencies: ["FeatureHome"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ScreenCoreTests",
            dependencies: ["ScreenCore"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FeatureHomeTests",
            dependencies: ["FeatureHome"],
            swiftSettings: swiftSettings
        )
    ]
)
