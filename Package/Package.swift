// swift-tools-version: 6.2

// モジュール名は層を接頭辞に持たせる（Core / Feature* / AppRoot）。
// 名前の変更は全 import に波及するが、フォルダ構成は path: を直すだけで済むため、
// フォルダは平坦のまま始める。モジュールが 10 個を超えたら階層化を見直す。

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "FeatureHome", targets: ["FeatureHome"]),
        .library(name: "AppRoot", targets: ["AppRoot"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/yossibank/kmp-app-template.git",
            exact: "0.6.0"
        )
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Shared", package: "kmp-app-template")
            ]
        ),
        .target(
            name: "FeatureHome",
            dependencies: ["Core"]
        ),
        .target(
            name: "AppRoot",
            dependencies: ["FeatureHome"]
        )
    ]
)
