// swift-tools-version: 6.2

import Foundation
import PackageDescription

let sharedDir = Context.environment["SHARED_DIR"]

let shared: (dependency: Package.Dependency, identity: String) = if let sharedDir {
    (.package(path: sharedDir), URL(fileURLWithPath: sharedDir).lastPathComponent)
} else {
    (.package(url: "https://github.com/yossibank/kmp-app-template.git", exact: "0.21.0"), "kmp-app-template")
}

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
        shared.dependency
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
                "ScreenCore",
                .product(
                    name: "Shared",
                    package: shared.identity
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
            dependencies: ["ScreenCore", "SharedCore"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FeatureHomeTests",
            dependencies: ["FeatureHome"],
            swiftSettings: swiftSettings
        )
    ]
)
