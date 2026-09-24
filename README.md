<div align="center">

# ios-app-template

SwiftUI と Kotlin Multiplatform で作る、ポケモン図鑑アプリのテンプレート

[![Verify](https://github.com/yossibank/ios-app-template/actions/workflows/verify.yml/badge.svg)](https://github.com/yossibank/ios-app-template/actions/workflows/verify.yml)
[![License](https://img.shields.io/github/license/yossibank/ios-app-template)](LICENSE)

![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0D96F6?logo=swift&logoColor=white)
![Swift Testing](https://img.shields.io/badge/Swift_Testing-555555?logo=swift&logoColor=white)
![Kotlin Multiplatform](https://img.shields.io/badge/Kotlin_Multiplatform-7F52FF?logo=kotlin&logoColor=white)

<img src="docs/images/demo.gif" width="260" alt="起動して一覧を読み込むまで">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/list-dark.png">
  <img src="docs/images/list-light.png" width="260" alt="ポケモンの一覧">
</picture>

</div>

PokeAPI のポケモンを、無限スクロール・タイプでの絞り込み・並び替え・詳細画面で見られます。データの取得とページングは共通コア（Kotlin Multiplatform）が担い、このリポジトリは iOS の画面と状態管理だけを持ちます。

## 3 つのリポジトリ

```mermaid
flowchart LR
    KMP["kmp-app-template<br/>共通ロジック"]
    AND["android-app-template<br/>Android アプリ"]
    IOS["ios-app-template<br/>iOS アプリ"]
    KMP -->|"AAR / klib"| AND
    KMP -->|"Shared.xcframework"| IOS
```

[kmp-app-template](https://github.com/yossibank/kmp-app-template) ・ [android-app-template](https://github.com/yossibank/android-app-template)

## モジュール構成

```mermaid
flowchart LR
    SHARED["Shared<br/><i>共通コア</i>"]
    SHAREDCORE["SharedCore"]
    SCREENCORE["ScreenCore"]
    HOME["FeatureHome"]
    ROOT["AppRoot"]
    SHARED --> SHAREDCORE --> HOME
    SCREENCORE --> HOME
    HOME --> ROOT
```

| モジュール | 役割 |
| --- | --- |
| `SharedCore` | 共通コアとの境界。KMP の型を Swift の型に直して渡す |
| `ScreenCore` | 画面の土台（読み込み状態の管理）と、機能に依らない UI 部品 |
| `FeatureHome` | 一覧と詳細の画面 |
| `AppRoot` | 画面の組み立て |

## 動かし方

> [!NOTE]
> 共通コアを GitHub から取得するため、`~/.netrc` に `api.github.com` の資格情報が必要です。

<details>
<summary>手順</summary>

1. `make bootstrap` で SwiftFormat / SwiftLint を用意する
2. `make open` で `AppTemplate.xcworkspace` を開く
3. 変更したら `make verify` を通す

</details>
